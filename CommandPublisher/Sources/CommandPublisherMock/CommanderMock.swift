//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Combine
import CommandPublisher
import protocol CommandPublisher.AsyncCommand
import Foundation
@testable import SwiftShell

public struct CommanderMock: Commander {
    public struct AllowedCommand {
        let type: Any.Type
        let stdout: String

        public init<Type: Command>(type: Type.Type, stdout: String = "") {
            self.stdout = stdout
            self.type = type
        }
    }

    public struct AllowedAsyncCommand {
        let type: Any.Type

        public init<Type: AsyncCommand>(type: Type.Type) {
            self.type = type
        }
    }

    public enum CommanderMockError: Error {
        case disallowedCommand
    }

    public let allowedCommands: [AllowedCommand]
    public let allowedAsyncCommands: [AllowedAsyncCommand]

    public init(allowedCommands: [AllowedCommand] = [], allowedAsyncCommands: [AllowedAsyncCommand] = []) {
        self.allowedCommands = allowedCommands
        self.allowedAsyncCommands = allowedAsyncCommands
    }

    public func run<CommandType: Command>(command: CommandType) -> AnyPublisher<CommandType.Result, Swift.Error> {
        guard let allowedCommand = allowedCommands.first(where: { $0.type is CommandType.Type }) else {
            return Fail(error: CommanderMockError.disallowedCommand)
                .eraseToAnyPublisher()
        }

        return Future { promise in
            do {
                let result = try command.parse(stdout: allowedCommand.stdout)
                promise(.success(result))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func run<AsyncCommandType>(command _: AsyncCommandType) -> AnyPublisher<CommandPublisher.Result, Swift.Error> where AsyncCommandType: AsyncCommand {
        guard allowedAsyncCommands.contains(where: { $0.type is AsyncCommandType.Type }) else {
            return Fail(error: CommanderMockError.disallowedCommand)
                .eraseToAnyPublisher()
        }

        return Future<CommandPublisher.Result, Swift.Error> { $0(.success(CommandPublisher.Result.started)) }
            .eraseToAnyPublisher()
    }
}
