//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import Combine
import Foundation
import SwiftShell

public struct ShellCommander: Commander {
    public let helperPath: URL
    public let context: Context & CommandRunning

    public init(helperPath: URL, context: Context & CommandRunning = CustomContext(main)) {
        self.helperPath = helperPath
        self.context = context
    }

    public func run<CommandType: Command>(command: CommandType) -> AnyPublisher<CommandType.Result, Swift.Error> {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        case let .custom(path):
            executable = path
        }
        return CommandPublisher(context: context,
                                command: executable,
                                parameters: command.parameters)
            .filter { result -> Bool in
                switch result {
                case .finished:
                    return true
                case .started:
                    return false
                }
            }
            .tryMap {
                switch $0 {
                case let .finished(stdout, _):
                    return try command.parse(stdout: stdout)
                case .started:
                    assert(false, "shouldn't be here")
                    return try command.parse(stdout: "")
                }
            }
            .eraseToAnyPublisher()
    }

    public func run<AsyncCommandType>(command: AsyncCommandType) -> AnyPublisher<CommandPublisher.Result, Error> where AsyncCommandType: AsyncCommand {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        case let .custom(path):
            executable = path
        }
        return CommandPublisher(context: context,
                                command: executable,
                                parameters: command.parameters)
            .eraseToAnyPublisher()
    }
}
