//
//  AndriodEmulator.swift
//
//
//  Created by vlsolome on 10/9/20.
//

import Combine
import CommandPublisher
import SwiftShell
import SwiftUI

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
        static let startingTimeout = 30
    }

    @Published public private(set) var state: State = .stopped(nil)
    private let commander: Commander
    private var process: CommanderProcess?
    private var cancellables = Set<AnyCancellable>()

    public convenience init() {
        self.init(commander: ShellCommander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!))
    }

    init(commander: Commander) {
        self.commander = commander
    }

    public func start() {
        guard process?.isRunning != true else {
            assert(false, "already running")
            return
        }
        startEmulator()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        checkEmulatorState()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func stop() {
        state = .stopping
        process?.stop()
    }

    public func configure(proxy: String?, caPath: URL?) {
        process?.onCompletion {}
        process = nil
        let publisher = commander.run(command: CreateEmulatorCommand(proxy: proxy, caPath: caPath))
            .timeout(.seconds(Config.configuringTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.configuringTimeout })
            .map { _ in State.stopped(nil) }
            .catch { error in Just(.notConfigured(error)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .stopped:
                    return self.startEmulator()
                        .eraseToAnyPublisher()
                default:
                    return Just(state)
                        .eraseToAnyPublisher()
                }
            }

        Publishers.Merge(Just(State.configuring), publisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startEmulator() -> AnyPublisher<State, Never> {
        process = commander.run(command: StartEmulatorCommand())
        process?.onCompletion {
            DispatchQueue.main.async { [weak self] in
                self?.state = .stopped(nil)
                self?.process?.onCompletion {}
                self?.process = nil
            }
        }

        let publisher = commander.run(command: WaitBootedCommand())
            .map { [weak self] _ -> State in
                if self?.process?.isRunning == true {
                    return .started
                } else {
                    return .stopped(nil)
                }
            }
            .timeout(.seconds(Config.waitBootingTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.bootingTimeout })
            .catch { Just(.stopped($0)) }
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
            let emulator = AOSEmulator()
            emulator.state = state
            return emulator
        }
    }
#endif
