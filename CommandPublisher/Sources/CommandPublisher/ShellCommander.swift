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
    public let context: Context & CommandRunning = CustomContext(main)
    public let helperPath: URL

    public init(helperPath: URL) {
        self.helperPath = helperPath
    }

    public func run<CommandType: Command>(command: CommandType) -> AnyPublisher<CommandType.Result, Swift.Error> {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
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
                case let .finished(cmd):
                    return try command.parse(stdout: Array(cmd.stdout.lines()))
                case let .started(cmd):
                    assert(false, "shouldn't be here")
                    return try command.parse(stdout: Array(cmd.stdout.lines()))
                }
            }
            .eraseToAnyPublisher()
    }

    public func run<AsyncCommandType>(command: AsyncCommandType) -> AnyPublisher<CommandPublisher.Result, Error> where AsyncCommandType: AsyncCommand {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        }
        return CommandPublisher(context: context,
                                command: executable,
                                parameters: command.parameters)
            .eraseToAnyPublisher()
    }
}
