//
//  SwiftUIView.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import CommandPublisher
import Foundation

public class AppManager: ObservableObject {
    public enum State {
        case notInstalled(Error?), installed(error: Error?, defaults: Any?), installing(Error?), starting(Error?), checking
    }

    public enum AppManagerError: Swift.Error {
        case wrongPath, wrongFormat, notInstalled
    }

    public struct Defaults {
        let path: [String]
        let data: Any

        public init(path: [String], data: Any) {
            self.path = path
            self.data = data
        }
    }

    @Published public var state: State = .notInstalled(nil)
    public let simulatorId: String
    public let bundleId: String
    private var cancellables: [AnyCancellable] = []
    private let commander: Commander

    public convenience init(simulatorId: String, bundleId: String) {
        self.init(simulatorId: simulatorId,
                  bundleId: bundleId,
                  commander: ShellCommander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!))
    }

    init(simulatorId: String, bundleId: String, commander: Commander) {
        self.simulatorId = simulatorId
        self.bundleId = bundleId
        self.commander = commander
    }

    public func install(app: URL, defaults: Defaults? = nil) {
        let command = commander.run(command: InstallAppCommand(id: simulatorId, path: app))
            .map { State.installed(error: nil, defaults: nil) }
            .catch { Just(State.notInstalled($0)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .installed:
                    return self.writeDefaults(defaults: defaults)
                        .map { _ in state }
                        .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                            guard let self = self else {
                                return Just(state)
                                    .eraseToAnyPublisher()
                            }
                            return self.startApp()
                        }
                        .eraseToAnyPublisher()
                default:
                    return Just(state)
                        .eraseToAnyPublisher()
                }
            }
        Publishers.Merge(Just(.installing(nil)), command)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        checkApp(upstreamError: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func start() {
        startApp()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startApp() -> AnyPublisher<State, Never> {
        SimulatorApp.shared.open()
        let command = commander.run(command: RunAppCommand(id: simulatorId, bundleId: bundleId))
            .map { .starting(nil) }
            .catch { error -> AnyPublisher<State, Never> in
                Just(.starting(error))
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.starting(nil))
                        .eraseToAnyPublisher()
                }
                let error: Error?
                switch state {
                case let .starting(err):
                    error = err
                default:
                    error = nil
                }

                return self.checkApp(upstreamError: error)
            }
            .eraseToAnyPublisher()
        return Publishers.Merge(Just(.starting(nil)), command)
            .eraseToAnyPublisher()
    }

    private func checkApp(upstreamError: Error?) -> AnyPublisher<State, Never> {
        let command = commander.run(command: ReadDefaultsCommand(id: simulatorId, bundleId: bundleId))
            .map { State.installed(error: upstreamError, defaults: $0) }
            .catch { Just(.notInstalled($0)) }
        return Publishers.Merge(Just(.checking), command)
            .eraseToAnyPublisher()
    }

    private func writeDefaults(defaults: Defaults?) -> AnyPublisher<State, Never> {
        guard let defaults = defaults else {
            return Just(.installing(nil))
                .eraseToAnyPublisher()
        }

        let command = commander.run(command: WriteDefaultsCommand(id: simulatorId, bundleId: bundleId, defaults: defaults))
            .map { .installing(nil) }
            .catch { error -> AnyPublisher<State, Never> in
                Just(.installing(error))
                    .eraseToAnyPublisher()
            }
        return Publishers.Merge(Just(.installing(nil)), command)
            .eraseToAnyPublisher()
    }
}

extension AppManager.State: Equatable {
    public static func == (lhs: AppManager.State, rhs: AppManager.State) -> Bool {
        switch (lhs, rhs) {
        case let (.installed(re, rd), .installed(le, ld)):
            let dCompare: Bool
            if let rdd = rd as? NSDictionary, let ldd = ld as? NSDictionary {
                dCompare = rdd.isEqual(to: ldd)
            } else {
                dCompare = rd == nil && ld == nil
            }

            return ((re == nil && le == nil) || (re != nil && le != nil)) &&
                dCompare
        case let (.notInstalled(r), .notInstalled(l)):
            return (r == nil && l == nil) || (r != nil && l != nil)
        case (.installing, .installing),
             (.starting, .starting),
             (.checking, .checking):
            return true
        default:
            return false
        }
    }
}

#if DEBUG
    public extension AppManager {
        static func preview(state: State = .notInstalled(nil)) -> AppManager {
            let manager = AppManager(simulatorId: "test", bundleId: "test")
            manager.state = state
            return manager
        }

        func set(state: State) {
            self.state = state
        }
    }
#endif
