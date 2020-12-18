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

private let subsystem = "com.coupand.CoupangMobileApp"
enum Log {
    static let table = OSLog(subsystem: subsystem, category: "CommandPublisher")
}

public struct CommandPublisher: Publisher {
    public typealias Output = RunOutput
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
    SubscriberType.Input == RunOutput,
    SubscriberType.Failure == Error
{
    private let subscriber: SubscriberType?
    private let context: Context & CommandRunning
    private let command: String
    private let parameters: [String]?

    init(subscriber: SubscriberType, context: Context & CommandRunning, command: String, parameters: [String]?) {
        self.subscriber = subscriber
        self.context = context
        self.command = command
        self.parameters = parameters
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let output = self.context.run(self.command, self.parameters ?? [], combineOutput: true)
            let c = self.command + " " + (self.parameters ?? []).joined(separator: " ")
            if let error = output.error {
                os_log("%{public}@\n%{public}@", log: Log.table, type: .error, c, output.stdout.lines().joined(separator: "\n"))
                self.subscriber?.receive(completion: .failure(error))
                return
            }
            os_log("%{public}@\n%{public}@", log: Log.table, type: .info, c, output.stdout.lines().joined(separator: "\n"))
            _ = self.subscriber?.receive(output)
            self.subscriber?.receive(completion: .finished)
        }
    }

    func cancel() {}
}

public struct AsyncCommandPublisher: Publisher {
    public typealias Output = AsyncCommand
    public typealias Failure = Error

    public let context: Context & CommandRunning
    public let command: String
    public let parameters: [String]?
    public let returnImmediately: Bool

    public init(context: Context & CommandRunning, command: String, parameters: [String]?, returnImmediately: Bool) {
        self.context = context
        self.command = command
        self.parameters = parameters
        self.returnImmediately = returnImmediately
    }

    public func receive<S>(subscriber: S) where S: Subscriber,
        Self.Failure == S.Failure,
        Self.Output == S.Input
    {
        let subscription = AsyncCommandSubscription(subscriber: subscriber, context: context, command: command, parameters: parameters, returnImmediately: returnImmediately)
        subscriber.receive(subscription: subscription)
    }
}

final class AsyncCommandSubscription<SubscriberType: Subscriber>: Subscription where
    SubscriberType.Input == AsyncCommand,
    SubscriberType.Failure == Error
{
    private let subscriber: SubscriberType?
    private let context: Context & CommandRunning
    private let command: String
    private let parameters: [String]?
    private var process: AsyncCommand?
    private let returnImmediately: Bool

    init(subscriber: SubscriberType, context: Context & CommandRunning, command: String, parameters: [String]?, returnImmediately: Bool) {
        self.subscriber = subscriber
        self.context = context
        self.command = command
        self.parameters = parameters
        self.returnImmediately = returnImmediately
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let c = self.command + " " + (self.parameters ?? []).joined(separator: " ")
            let process = self.context.runAsync(self.command, self.parameters ?? [])
            os_log("async %{public}@", log: Log.table, type: .info, c)
            self.process = process
            _ = self.subscriber?.receive(process)
            if self.returnImmediately {
                self.subscriber?.receive(completion: .finished)
            } else {
                process.onCompletion { _ in
                    self.subscriber?.receive(completion: .finished)
                }
            }
        }
    }

    func cancel() {
        process?.stop()
    }
}

extension CommandError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
