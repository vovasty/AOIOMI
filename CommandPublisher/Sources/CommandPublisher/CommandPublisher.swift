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

    public struct CommandError: Error {
        let error: Error
        let output: [String]
    }

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
            let output = self.context.run(self.command, self.parameters ?? [], combineOutput: false)
            if let error = output.error {
                print("=========stdout===========")
                print(output.stdout)
                print("=========stderror===========")
                print(output.stderror)
                self.subscriber?.receive(completion: .failure(error))
                return
            }
            _ = self.subscriber?.receive(output)
            self.subscriber?.receive(completion: .finished)
        }
    }

    func cancel() {}
}

extension CommandError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
