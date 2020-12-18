import Combine
import Foundation
import SwiftShell

public struct AndroidEmulatorConfig: Decodable {
    public struct Command: Decodable {
        public enum Parameter {
            case install_ca(String), set_proxy(String), install_apk(String), predefined(String), get_file_path(String, String), app_activity_id(String), app_package_id(String)
        }

        public let name: String
        public var command: String
        public var arguments: [Parameter]
        public let async: Bool
    }

    public struct Commands: Decodable {
        let is_created: Command
        let start: Command
        let install_apk: Command
        let create: [Command]
        let run_app: Command
        let get_file: [Command]
        let wait_booted: Command
        let get_emulator_pid: Command
        let is_app_installed: Command
    }

    var commands: Commands
}

extension AndroidEmulatorConfig.Command.Parameter: Decodable {
    enum CodingKeys: CodingKey {
        case install_ca, set_proxy, install_apk, predefined, get_file_path, app_activity_id, app_package_id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .install_apk:
            self = .install_apk("")
        case .set_proxy:
            self = .set_proxy("")
        case .install_ca:
            self = .install_ca("")
        case .get_file_path:
            self = .get_file_path("", "")
        case .predefined:
            let predefined = try container.decode(
                String.self,
                forKey: .predefined
            )
            self = .predefined(predefined)
        case .app_activity_id:
            self = .app_activity_id("")
        case .app_package_id:
            self = .app_package_id("")
        case .none:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

public extension AndroidEmulatorConfig.Command.Parameter {
    var asString: [String] {
        switch self {
        case let .install_apk(path):
            return ["install_apk", path]
        case let .set_proxy(proxy):
            return ["set_proxy", proxy]
        case let .install_ca(path):
            return ["install_ca", path]
        case let .predefined(command):
            return [command]
        case let .get_file_path(in_path, out_path):
            return [in_path, out_path]
        case let .app_activity_id(id):
            return [id]
        case let .app_package_id(id):
            return [id]
        }
    }
}

public extension Array where Element == AndroidEmulatorConfig.Command.Parameter {
    var asString: [String] {
        flatMap(\.asString)
    }
}

class AndroidEmulatorRunner {
    enum Error: Swift.Error {
        case unexpectedParameter(AndroidEmulatorConfig.Command.Parameter)
        case unknown(String)
        case notStarted
    }

    private let rootPath: URL
    private let context: Context & CommandRunning
    private let config: AndroidEmulatorConfig
    private var pid: String?
    private var isStarted: Bool {
        pid != nil
    }

    public init(rootPath: URL) throws {
        self.rootPath = rootPath
        context = CustomContext(main)
        let data = try Data(contentsOf: rootPath.appendingPathComponent("config.json"))
        config = try JSONDecoder().decode(AndroidEmulatorConfig.self, from: data)
    }

    public func start() -> AnyPublisher<Void, Swift.Error> {
        guard !isStarted else {
            assert(false)
            return Fail<Void, Swift.Error>(error: Error.notStarted)
                .eraseToAnyPublisher()
        }

        let get_emulator_pid = config.commands.get_emulator_pid
        let start = config.commands.start
        let get_emulator_pid_parameters: [AndroidEmulatorConfig.Command.Parameter]
        let start_parameters: [AndroidEmulatorConfig.Command.Parameter]

        do {
            get_emulator_pid_parameters = try parametrize(parameters: get_emulator_pid.arguments)
            start_parameters = try parametrize(parameters: start.arguments)
        } catch {
            return Fail<Void, Swift.Error>(error: error)
                .eraseToAnyPublisher()
        }

        return run(command: get_emulator_pid.command, parameters: get_emulator_pid_parameters)
            .map {
                self.pid = $0.stdout
                return ()
            }
            .catch { _ -> AnyPublisher<Void, Swift.Error> in
                self.runAsync(command: start.command, returnImmediately: true, parameters: start_parameters)
                    .flatMap { _ in
                        self.waitBooted(timeout: 30)
                            .collect()
                            .flatMap { _ in
                                self.run(command: get_emulator_pid.command, parameters: get_emulator_pid_parameters)
                                    .map {
                                        self.pid = $0.stdout
                                        return ()
                                    }
                            }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func stop() {
//        guard let pid = pid else {
//            assert(false)
//            return
//        }
//        command.stop()
    }

    public func install(apk: String) -> AnyPublisher<Void, Swift.Error> {
        guard isStarted else {
            return Fail<Void, Swift.Error>(error: Error.notStarted)
                .eraseToAnyPublisher()
        }

        let command = config.commands.install_apk
        return run(command: command.command, parameters: try parametrize(parameters: command.arguments, apkPath: apk))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func get(file path: String) -> AnyPublisher<Data, Swift.Error> {
        guard isStarted else {
            return Fail<Data, Swift.Error>(error: Error.notStarted)
                .eraseToAnyPublisher()
        }
        let tmpPath = getTempFile()

        var commands = [AnyPublisher<RunOutput, Swift.Error>]()
        for command in config.commands.get_file {
            let res = run(command: command.command, parameters: try parametrize(parameters: command.arguments, getFilePath: (path, tmpPath.path)))
                .eraseToAnyPublisher()
            commands.append(res)
        }

        return commands.serialize()!
            .collect()
            .tryMap { _ in
                let data = try Data(contentsOf: tmpPath)
                try FileManager.default.removeItem(at: tmpPath)
                return data
            }
            .eraseToAnyPublisher()
    }

    public func waitBooted(timeout: Int) -> AnyPublisher<Void, Swift.Error> {
        let command = config.commands.wait_booted
        return runAsync(command: command.command,
                        returnImmediately: false,
                        parameters: try parametrize(parameters: command.arguments))
            .timeout(.seconds(timeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.unknown("timeout") })
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func runApp(appActivityId: String) -> AnyPublisher<Void, Swift.Error> {
        guard isStarted else {
            return Fail<Void, Swift.Error>(error: Error.notStarted)
                .eraseToAnyPublisher()
        }

        let command = config.commands.run_app
        return run(command: command.command, parameters: try parametrize(parameters: command.arguments, appActivityId: appActivityId))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func isCreated() -> AnyPublisher<Void, Swift.Error> {
        let command = config.commands.is_created
        return run(command: command.command, parameters: try parametrize(parameters: command.arguments))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func isRunning() -> AnyPublisher<Void, Swift.Error> {
        let command = config.commands.get_emulator_pid
        return run(command: command.command, parameters: try parametrize(parameters: command.arguments))
            .receive(on: DispatchQueue.main)
            .map {
                self.pid = $0.stdout
                return ()
            }
            .eraseToAnyPublisher()
    }

    public func isAppInstalled(appPackageId: String) -> AnyPublisher<Void, Swift.Error> {
        let command = config.commands.is_app_installed
        return run(command: command.command, parameters: try parametrize(parameters: command.arguments, appPackageId: appPackageId))
            .receive(on: DispatchQueue.main)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func configure(caPath: String, proxy: String) -> AnyPublisher<Void, Swift.Error> {
        var commands = [AnyPublisher<Void, Swift.Error>]()
        for command in config.commands.create {
            let cmd: AnyPublisher<Void, Swift.Error>

            if command.async {
                cmd = runAsync(command: command.command, returnImmediately: true, parameters: try parametrize(parameters: command.arguments, caPath: caPath, proxy: proxy))
                    .map { _ in () }
                    .eraseToAnyPublisher()
            } else {
                cmd = run(command: command.command, parameters: try parametrize(parameters: command.arguments, caPath: caPath, proxy: proxy))
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            commands.append(cmd)
        }

        return commands.serialize()!
            .collect()
            .flatMap { _ in
                self.isRunning()
            }
            .eraseToAnyPublisher()
    }

    private func expand(command: String) -> String {
        rootPath.appendingPathComponent(command, isDirectory: false).path
    }

    private func parametrize(parameters: [AndroidEmulatorConfig.Command.Parameter], apkPath: String? = nil, caPath: String? = nil, proxy: String? = nil, appActivityId: String? = nil, appPackageId: String? = nil, getFilePath: (String, String)? = nil) throws -> [AndroidEmulatorConfig.Command.Parameter] {
        try parameters.map { parameter -> AndroidEmulatorConfig.Command.Parameter in
            switch parameter {
            case .install_apk:
                guard let path = apkPath else { throw Error.unexpectedParameter(parameter) }
                return .install_apk(path)
            case .install_ca:
                guard let path = caPath else { throw Error.unexpectedParameter(parameter) }
                return .install_ca(path)
            case .set_proxy:
                guard let proxy = proxy else { throw Error.unexpectedParameter(parameter) }
                return .set_proxy(proxy)
            case .predefined:
                return parameter
            case .get_file_path:
                guard let getFilePath = getFilePath else { throw Error.unexpectedParameter(parameter) }
                return .get_file_path(getFilePath.0, getFilePath.1)
            case .app_activity_id:
                guard let appActivityId = appActivityId else { throw Error.unexpectedParameter(parameter) }
                return .app_activity_id(appActivityId)
            case .app_package_id:
                guard let appPackageId = appPackageId else { throw Error.unexpectedParameter(parameter) }
                return .app_package_id(appPackageId)
            }
        }
    }

    private func run(command: String, parameters: @autoclosure () throws -> [AndroidEmulatorConfig.Command.Parameter]) -> AnyPublisher<RunOutput, Swift.Error> {
        do {
            let command = expand(command: command)
            let params = try parameters().asString
            return CommandPublisher(context: context,
                                    command: command,
                                    parameters: params)
                .eraseToAnyPublisher()

        } catch {
            return Fail<RunOutput, Swift.Error>(error: error)
                .eraseToAnyPublisher()
        }
    }

    private func runAsync(command: String, returnImmediately: Bool, parameters: @autoclosure () throws -> [AndroidEmulatorConfig.Command.Parameter]) -> AnyPublisher<AsyncCommand, Swift.Error> {
        do {
            let command = expand(command: command)
            let params = try parameters().asString
            return AsyncCommandPublisher(context: context,
                                         command: command,
                                         parameters: params,
                                         returnImmediately: returnImmediately)
                .eraseToAnyPublisher()

        } catch {
            return Fail<AsyncCommand, Swift.Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}

extension AndroidEmulatorRunner.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notStarted:
            return "Emulator is not running"
        case let .unexpectedParameter(parameter):
            return "Unexpected command parameter: \(parameter.asString)"
        case let .unknown(error):
            return "Unknown error: \(error)"
        }
    }
}
