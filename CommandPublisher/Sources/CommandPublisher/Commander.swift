//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import Combine
import Foundation
import SwiftShell

public struct Commander {
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
                try command.parse(stdout: $0.stdout.lines())
            }
            .eraseToAnyPublisher()
    }

    public func run(command: AsyncCommand) -> SwiftShell.AsyncCommand {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        }
        return context.runAsync(executable, command.parameters ?? [])
    }
}
