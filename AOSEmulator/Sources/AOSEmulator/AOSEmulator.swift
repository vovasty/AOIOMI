//
//  AndriodEmulator.swift
//
//
//  Created by vlsolome on 10/9/20.
//

import Combine
import CommandPublisher
import Foundation
import SwiftShell

public class AOSEmulator: ObservableObject {
    public enum State {
        case started, starting, stopped(Swift.Error?), stopping, configuring, checking, notConfigured(Swift.Error?)
    }

    enum Error: Swift.Error {
        case unknown(String)
        case bootingTimeout
        case configuringTimeout
    }

    enum Config {
        static let waitBootingTimeout = 30
        static let configuringTimeout = 180
    }

    @Published public private(set) var state: State = .stopped(nil)
    private let commander: Commander
    private var cancellables = Set<AnyCancellable>()
    private var process: AnyCancellable?

    public convenience init(env: [String: String]) {
        var context = CustomContext(main)
        context.env.merge(env) { _, new in new }
        self.init(commander: ShellCommander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!,
                                            context: context))
    }

    init(commander: Commander) {
        self.commander = commander
    }

    public func start() {
        process?.cancel()
        process = startEmulator()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
    }

    public func check() {
        checkEmulatorState()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func stop() {
        state = .stopping
        process?.cancel()
    }

    public func configure(proxy: String?, caPath: [URL]?) {
        process?.cancel()
        let publisher = commander.run(command: CreateEmulatorCommand(proxy: proxy, caPath: caPath))
            .timeout(.seconds(Config.configuringTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.configuringTimeout })
            .flatMap { [weak self] _ -> AnyPublisher<State, Swift.Error> in
                guard let self = self else {
                    return Future { $0(.success(State.configuring)) }
                        .eraseToAnyPublisher()
                }
                return self.startEmulator()
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }
            .catch { error in
                Just(.notConfigured(error))
            }

        process = Publishers.Merge(Just(State.configuring), publisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
    }

    private func startEmulator() -> AnyPublisher<State, Never> {
        let publisher = commander.run(command: StartEmulatorCommand())
            .flatMap { [weak self] state -> AnyPublisher<State, Swift.Error> in
                guard let self = self else {
                    return Future { $0(.success(State.starting)) }
                        .eraseToAnyPublisher()
                }
                switch state {
                case .started:
                    return self.commander.run(command: WaitBootedCommand())
                        .map { _ -> State in .started }
                        .timeout(.seconds(Config.waitBootingTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.bootingTimeout })
                        .catch {
                            Just(State.stopped($0))
                        }
                        .setFailureType(to: Swift.Error.self)
                        .eraseToAnyPublisher()
                case .finished:
                    return Future { $0(.success(State.stopped(nil))) }
                        .eraseToAnyPublisher()
                }
            }
            .replaceError(with: State.stopped(nil))
            .eraseToAnyPublisher()

        return Publishers.Merge(Just(State.starting), publisher)
            .eraseToAnyPublisher()
    }

    private func checkEmulatorState() -> AnyPublisher<State, Never> {
        let publisher = commander.run(command: IsEmulatorCreatedCommand())
            .map { _ in State.stopped(nil) }
            .catch { _ in Just(.notConfigured(nil)) }

        return Publishers.Merge(Just(State.checking), publisher)
            .eraseToAnyPublisher()
    }
}

extension AOSEmulator.State: Equatable {
    public static func == (lhs: AOSEmulator.State, rhs: AOSEmulator.State) -> Bool {
        switch (lhs, rhs) {
        case let (.stopped(r), .stopped(l)):
            return (r == nil && l == nil) || (r != nil && l != nil)
        case let (.notConfigured(r), .notConfigured(l)):
            return (r == nil && l == nil) || (r != nil && l != nil)
        case (.started, .started),
             (.starting, .starting),
             (.stopping, .stopping),
             (.configuring, .configuring),
             (.checking, .checking):
            return true
        default:
            return false
        }
    }
}

#if DEBUG
    public extension AOSEmulator {
        static func preview(state: State = .stopped(nil)) -> AOSEmulator {
            let emulator = AOSEmulator(commander: ShellCommander(helperPath: URL(fileURLWithPath: "/nonexisting")))
            emulator.state = state
            return emulator
        }
    }
#endif
