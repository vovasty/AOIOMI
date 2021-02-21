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
            .tryMap {
                try command.parse(stdout: Array($0.stdout.lines()))
            }
            .eraseToAnyPublisher()
    }

    public func run<AsyncCommandType>(command: AsyncCommandType) -> AnyPublisher<AsyncCommandPublisher.Result, Error> where AsyncCommandType: AsyncCommand {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        }
        return AsyncCommandPublisher(context: context,
                                     command: executable,
                                     parameters: command.parameters)
            .eraseToAnyPublisher()
    }
}
