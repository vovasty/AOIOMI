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
import SwiftShell

public struct CommanderMock: Commander {
    public struct AllowedCommand {
        let type: Any.Type
        let stdout: [String]

        public init<Type: Command>(type: Type.Type, stdout: [String]) {
            self.stdout = stdout
            self.type = type
        }
    }

    public enum CommanderMockError: Error {
        case disallowedCommand
    }

    public class Process: CommanderProcess {
        public private(set) var isRunning: Bool = true
        private var completionHandler: (() -> Void)?

        public func onCompletion(handler: @escaping () -> Void) {
            completionHandler = handler
        }

        public func stop() {
            isRunning = false
            completionHandler?()
        }
    }

    public let allowedCommands: [AllowedCommand]

    public init(allowedCommands: [AllowedCommand]) {
        self.allowedCommands = allowedCommands
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

    public func run(command _: AsyncCommand) -> CommanderProcess {
        Process()
    }
}
