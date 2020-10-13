import Foundation
import SwiftShell

public struct AndroidEmulatorConfig: Decodable {
    public struct Command: Decodable {
        public enum Parameter {
            case install_ca(String), set_proxy(String), install_apk(String), predefined(String)
        }

        public let name: String
        public var command: String
        public var arguments: [Parameter]
        public let async: Bool
    }

    public struct Commands: Decodable {
        var is_created: Command
        var start: Command
        var install_apk: Command
        var create: [Command]
    }

    var commands: Commands
}

extension AndroidEmulatorConfig.Command.Parameter: Decodable {
    enum CodingKeys: CodingKey {
        case install_ca, set_proxy, install_apk, predefined
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
        case .predefined:
            let predefined = try container.decode(
                String.self,
                forKey: .predefined
            )
            self = .predefined(predefined)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

extension AndroidEmulatorConfig.Command.Parameter {
    public var asString: [String] {
        switch self {
        case let .install_apk(path):
            return ["install_apk", path]
        case let .set_proxy(proxy):
            return ["set_proxy", proxy]
        case let .install_ca(path):
            return ["install_ca", path]
        case let .predefined(command):
            return [command]
        }
    }
}

extension Array where Element == AndroidEmulatorConfig.Command.Parameter {
    public var asString: [String] {
        map { $0.asString }.flatMap { $0 }
    }
}

protocol AndroidEmulatorRunnerDelegate: AnyObject {
    func started(command: AndroidEmulatorConfig.Command)
    func finished(command: AndroidEmulatorConfig.Command)
    func started(runner: AndroidEmulatorRunner)
    func stopped(runner: AndroidEmulatorRunner)
    func created(runner: AndroidEmulatorRunner, success: Bool)
    func isCreated(runner: AndroidEmulatorRunner, isCreated: Bool)
}

class AndroidEmulatorRunner {
    enum Error: Swift.Error {
        case unexpectedParameter(AndroidEmulatorConfig.Command.Parameter)
        case unknown(String)
    }

    private let rootPath: URL
    private let context: Context & CommandRunning
    private let config: AndroidEmulatorConfig
    weak var delegate: AndroidEmulatorRunnerDelegate?
    private var startCommand: AsyncCommand?
    private var isStarted: Bool {
        startCommand != nil
    }

    public init(rootPath: URL) throws {
        self.rootPath = rootPath
        context = CustomContext(main)
        let data = try Data(contentsOf: rootPath.appendingPathComponent("config.json"))
        config = try JSONDecoder().decode(AndroidEmulatorConfig.self, from: data)
    }

    public func start() {
        guard !isStarted else {
            assert(false)
            return
        }
        delegate?.started(runner: self)
        let command = config.commands.start
        let parameters = try! parametrize(parameters: command.arguments)
        startCommand = runAsync(command: command.command, parameters: parameters)
            .onCompletion { [weak self] cmd in
                guard let `self` = self else { return }
                self.delegate?.stopped(runner: self)
                for line in cmd.stdout.lines() {
                    print("stdout", line)
                }

                for line in cmd.stderror.lines() {
                    print("stderr", line)
                }
                self.startCommand = nil
            }
    }

    public func stop() {
        guard let command = startCommand else {
            assert(false)
            return
        }
        command.stop()
    }

    public func install(apk: String) {
        guard isStarted else {
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let command = self.config.commands.install_apk
                let parameters = try self.parametrize(parameters: command.arguments, apkPath: apk)
                let output = try self.run(command: command.command, parameters: parameters)
                print("stdout", output)
            } catch {
                print("error", error)
            }
        }
    }

    public func isCreated() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let command = self.config.commands.is_created
                let parameters = try self.parametrize(parameters: command.arguments)
                let output = try self.run(command: command.command, parameters: parameters)
                print("stdout", output)
                self.delegate?.isCreated(runner: self, isCreated: true)
            } catch {
                print("error", error)
                self.delegate?.created(runner: self, success: false)
            }
        }
    }

    public func configure(caPath: String, proxy: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            for command in self.config.commands.create {
                print(command)

                do {
                    let parameters = try self.parametrize(parameters: command.arguments, caPath: caPath, proxy: proxy)
                    if command.async {
                        _ = self.runAsync(command: command.command, parameters: parameters)
                            .onCompletion {
                                print("output", command.command, $0.stdout.lines())
                                print("stderr", command.command, $0.stderror.lines())
                            }
                    } else {
                        let output = try self.run(command: command.command, parameters: parameters)
                        print("stdout", output.stdout)
                    }
                } catch {
                    print("error", error)
                    self.delegate?.created(runner: self, success: false)
                    return
                }
            }
            self.delegate?.created(runner: self, success: true)
            self.start()
        }
    }

    private func expand(command: String) -> String {
        return rootPath.appendingPathComponent(command, isDirectory: false).path
    }

    private func parametrize(parameters: [AndroidEmulatorConfig.Command.Parameter], apkPath: String? = nil, caPath: String? = nil, proxy: String? = nil) throws -> [AndroidEmulatorConfig.Command.Parameter] {
        return try parameters.map { parameter -> AndroidEmulatorConfig.Command.Parameter in
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
            }
        }
    }

    private func run(command: String, parameters: [AndroidEmulatorConfig.Command.Parameter]) throws -> RunOutput {
        let command = expand(command: command)
        let parameters = parameters.asString
        let output = context.run(command, parameters, combineOutput: true)

        guard output.error == nil else {
            throw output.error!
        }

        guard output.succeeded else {
            throw Error.unknown(output.stdout)
        }

        return output
    }

    private func runAsync(command: String, parameters: [AndroidEmulatorConfig.Command.Parameter]) -> AsyncCommand {
        let command = expand(command: command)
        let parameters = parameters.asString
        return context.runAsync(command, parameters)
    }
}
