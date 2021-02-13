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
import SWXMLHash

public class AndroidEmulator: ObservableObject {
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
    private var process: SwiftShell.AsyncCommand?
    private var cancellables = Set<AnyCancellable>()

    public init() throws {
        commander = Commander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!)
    }

    public func start() {
        guard process?.isRunning != true else {
            assert(false, "already running")
            return
        }
        state = .starting
        startEmulator()
            .catch { error in Just(.stopped(error)) }
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

    public func configure(proxy: String, caPath: URL) {
        state = .configuring
        commander.run(command: CreateEmulatorCommand(proxy: proxy, caPath: caPath))
            .timeout(.seconds(Config.configuringTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.configuringTimeout })
            .map { _ -> State in .configuring }
            .catch { error in Just(.notConfigured(error)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.stopped(nil))
                        .eraseToAnyPublisher()
                }
                switch state {
                case .configuring:
                    return self.startEmulator()
                        .catch { error in Just(.stopped(error)) }
                        .eraseToAnyPublisher()
                default:
                    return Just(state)
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startEmulator() -> AnyPublisher<State, Swift.Error> {
        process = commander.run(command: StartCommand())
        process?.onCompletion{ command in
            DispatchQueue.main.async {
                self.state = .stopped(nil)
            }
        }
        return waitBooted()
            .map { _ -> State in .started }
            .eraseToAnyPublisher()
    }

    private func checkEmulatorState() -> AnyPublisher<State, Never> {
        commander.run(command: IsCreatedCommand())
            .map { _ -> State in .checking }
            .catch { error in Just(.notConfigured(error)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.stopped(nil))
                        .eraseToAnyPublisher()
                }
                switch state {
                case .notConfigured:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.commander.run(command: GetEmulatorPIDCommand())
                        .map { _ in .started }
                        .catch { _ in Just(.stopped(nil)) }
                        .eraseToAnyPublisher()
                }
            }
            .collect()
            .map { $0.last ?? .notConfigured(nil) }
            .eraseToAnyPublisher()
    }

    private func waitBooted() -> AnyPublisher<Void, Swift.Error> {
        let command = WaitBootedCommand()
        return commander.run(command: command)
            .timeout(.seconds(Config.waitBootingTimeout), scheduler: DispatchQueue.global(qos: .background), options: nil, customError: { Error.bootingTimeout })
            .eraseToAnyPublisher()
    }
}
