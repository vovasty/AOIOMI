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
    public typealias Output = SwiftShell.AsyncCommand
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
    SubscriberType.Input == SwiftShell.AsyncCommand,
    SubscriberType.Failure == Error
{
    private let subscriber: SubscriberType?
    private var asyncCommand: SwiftShell.AsyncCommand?

    public struct CommandError: Error {
        public let errorCode: Int
        public let stdout: LazySequence<AnySequence<String>>
        public let stderror: LazySequence<AnySequence<String>>
    }

    init(subscriber: SubscriberType, context: Context & CommandRunning, command: String, parameters: [String]?) {
        self.subscriber = subscriber
        let debugCommand = command + " " + (parameters ?? []).joined(separator: " ")
        print("running", debugCommand)
        asyncCommand = context.runAsync(command, parameters ?? [])
        asyncCommand?.onCompletion { [weak self] cmd in
            let report = """
            finished \(cmd.exitcode()) \(debugCommand)
            """
            print(report)
            guard let self = self else { return }
            if cmd.exitcode() == 0 {
                _ = self.subscriber?.receive(cmd)
                self.subscriber?.receive(completion: .finished)
            } else {
                let error = CommandError(errorCode: cmd.exitcode(),
                                         stdout: cmd.stdout.lines(),
                                         stderror: cmd.stderror.lines())
                self.subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func request(_: Subscribers.Demand) {}

    func cancel() {
        asyncCommand?.stop()
    }
}

public struct AsyncCommandPublisher: Publisher {
    public enum Result {
        case started
        case finished
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
        let subscription = AsyncCommandSubscription(subscriber: subscriber, context: context, command: command, parameters: parameters)
        subscriber.receive(subscription: subscription)
    }
}

final class AsyncCommandSubscription<SubscriberType: Subscriber>: Subscription where
    SubscriberType.Input == AsyncCommandPublisher.Result,
    SubscriberType.Failure == Error
{
    private let subscriber: SubscriberType?
    private var asyncCommand: SwiftShell.AsyncCommand?

    public struct CommandError: Error {
        public let errorCode: Int
        public let stdout: LazySequence<AnySequence<String>>
        public let stderror: LazySequence<AnySequence<String>>
    }

    init(subscriber: SubscriberType, context: Context & CommandRunning, command: String, parameters: [String]?) {
        self.subscriber = subscriber
        let debugCommand = command + " " + (parameters ?? []).joined(separator: " ")
        print("running", debugCommand)
        let asyncCommand = context.runAsync(command, parameters ?? [])
        self.asyncCommand = asyncCommand
        _ = self.subscriber?.receive(.started)
        asyncCommand.onCompletion { [weak self] cmd in
            let report = """
            finished \(cmd.exitcode()) \(debugCommand)
            """
            print(report)
            guard let self = self else { return }
            if cmd.exitcode() == 0 {
                _ = self.subscriber?.receive(.finished)
                self.subscriber?.receive(completion: .finished)
            } else {
                let error = CommandError(errorCode: cmd.exitcode(),
                                         stdout: cmd.stdout.lines(),
                                         stderror: cmd.stderror.lines())
                self.subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func request(_: Subscribers.Demand) {}

    func cancel() {
        asyncCommand?.stop()
    }
}

extension CommandError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
