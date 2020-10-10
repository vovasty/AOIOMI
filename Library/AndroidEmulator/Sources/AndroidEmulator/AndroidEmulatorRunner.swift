import Foundation
import SwiftShell

public struct AndroidEmulatorConfig: Decodable {
    public struct Command: Decodable {
        public let name: String
        public var command: String
        public var arguments: [String]
        public let async: Bool
    }

    public struct Commands: Decodable {
        var is_created: Command
        var start: Command
        var create: [Command]
    }

    var commands: Commands
}

extension AndroidEmulatorConfig.Command {
    mutating func remapArguments(substitute: [String: String]) {
        arguments = arguments.map { substitute[$0] ?? $0 }
    }
}

extension AndroidEmulatorConfig {
    mutating func remapCommands(rootPath: String, caFile: String, httpProxy: String) {
        let substitute = ["{{CA_FILE}}": caFile,
                          "{{HTTP_PROXY}}": httpProxy]
        var start = commands.start
        start.remapArguments(substitute: substitute)
        start.command = "\(rootPath)/\(start.command)"

        let create = commands.create.map { command -> Command in
            var command = command
            command.remapArguments(substitute: substitute)
            command.command = "\(rootPath)/\(command.command)"
            return command
        }

        var is_created = commands.is_created
        is_created.remapArguments(substitute: substitute)
        is_created.command = "\(rootPath)/\(is_created.command)"

        commands.start = start
        commands.create = create
        commands.is_created = is_created
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
    private let rootPath: String
    private let context: Context & CommandRunning
    private let config: AndroidEmulatorConfig
    weak var delegate: AndroidEmulatorRunnerDelegate?
    private var startCommand: AsyncCommand?

    public init(rootPath: String, caPath: String, httpProxy: String) throws {
        self.rootPath = rootPath
        context = CustomContext(main)
        let data = try Data(contentsOf: URL(fileURLWithPath: rootPath).appendingPathComponent("config.json"))
        var config = try JSONDecoder().decode(AndroidEmulatorConfig.self, from: data)
        config.remapCommands(rootPath: rootPath, caFile: caPath, httpProxy: httpProxy)
        self.config = config
    }

    public func start() {
        guard startCommand == nil else {
            assert(startCommand == nil)
            return
        }
        delegate?.started(runner: self)
        let command = config.commands.start
        startCommand = context.runAsync(command.command, command.arguments).onCompletion { [weak self] cmd in
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
            assert(startCommand != nil)
            return
        }
        command.stop()
    }

    public func isCreated() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            let command = self.config.commands.is_created
            let output = self.context.run(command.command, command.arguments, combineOutput: true)
            print("stdout", output.stdout)
            guard output.error == nil, output.succeeded else {
                print("error", output.error)
                self.delegate?.isCreated(runner: self, isCreated: false)
                return
            }
            self.delegate?.isCreated(runner: self, isCreated: true)
        }
    }

    public func configure() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            for command in self.config.commands.create {
                print(command)
                if command.async {
                    _ = self.context.runAsync(command.command, command.arguments)
                } else {
                    let output = self.context.run(command.command, command.arguments, combineOutput: true)
                    print("stdout", output.stdout)
                    guard output.error == nil, output.succeeded else {
                        print("error", output.error)
                        self.delegate?.created(runner: self, success: false)
                        return
                    }
                }
            }
            self.delegate?.created(runner: self, success: true)
        }
    }
}
