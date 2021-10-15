//
//  File.swift
//
//
//  Created by vlsolome on 12/16/20.
//

import Combine
import Foundation
import os
import SwiftShell

public struct CommandPublisher: Publisher {
    public enum Result {
        case started
        case finished(stdout: String, stderr: String)
    }

    public struct CommandError: Error {
        public let command: String
        public let arguments: [String]?
        public let errorCode: Int
        public let stdout: String
        public let stderror: String
    }

    public typealias Output = Result
    public typealias Failure = Error

    public let context: Context & CommandRunning
    public let command: String
    public let parameters: [String]?

    public init(context: Context & CommandRunning, command: String, parameters: [String]?) {
        self.context = context
        self.command = command
        self.parameters = parameters
    }

    public func receive<S>(subscriber: S) where S: Subscriber,
        Self.Failure == S.Failure,
        Self.Output == S.Input
    {
        let subscription = CommandSubscription(subscriber: subscriber, context: context, command: command, parameters: parameters)
        subscriber.receive(subscription: subscription)
    }
}

final class CommandSubscription<SubscriberType: Subscriber>: Subscription where
    SubscriberType.Input == CommandPublisher.Result,
    SubscriberType.Failure == Error
{
    private let subscriber: SubscriberType?
    private var asyncCommand: SwiftShell.AsyncCommand?
    private let command: String
    private let parameters: [String]?
    private let context: Context & CommandRunning

    init(subscriber: SubscriberType, context: Context & CommandRunning, command: String, parameters: [String]?) {
        self.subscriber = subscriber
        self.command = command
        self.parameters = parameters
        self.context = context
    }

    func request(_ demand: Subscribers.Demand) {
        guard asyncCommand == nil else { return }
        guard demand > 0 else { return }

        let debugCommand = command + " " + (parameters ?? []).joined(separator: " ")
        print("running", debugCommand)
        let asyncCommand = context.runAsync(command, parameters ?? [])
        self.asyncCommand = asyncCommand
        _ = subscriber?.receive(.started)
        var stdout = ""
        var stderr = ""
        asyncCommand.stdout.onOutput { s in
            stdout += s.readSome() ?? ""
        }
        asyncCommand.stderror.onOutput { s in
            stderr += s.readSome() ?? ""
        }
        asyncCommand.onCompletion { [weak self] cmd in
            let report = """
            finished \(cmd.exitcode()) \(debugCommand)
            """
            print(report)
            guard let self = self else { return }
            if cmd.exitcode() == 0 {
                _ = self.subscriber?.receive(.finished(stdout: stdout, stderr: stderr))
                self.subscriber?.receive(completion: .finished)
            } else {
                let error = CommandPublisher.CommandError(command: self.command,
                                                          arguments: self.parameters,
                                                          errorCode: cmd.exitcode(),
                                                          stdout: stdout,
                                                          stderror: stderr)
                self.subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func cancel() {
        asyncCommand?.stop()
    }
}

extension CommandPublisher.CommandError: LocalizedError {
    public var errorDescription: String? {
        let params = (arguments ?? []).map { "\"\($0)\"" }.joined(separator: " ")
        return """
        \(command) \(params)
        error code: \(errorCode)
        "stdout:"
        \(stdout)
        "stderr:"
        \(stderror)
        """
    }
}
