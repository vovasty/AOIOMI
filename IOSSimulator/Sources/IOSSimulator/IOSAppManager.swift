//
//  SwiftUIView.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import CommandPublisher
import Foundation

public class IOSAppManager: ObservableObject {
    public enum State {
        case notInstalled(Error?), installed(error: Error?, defaults: Any?), installing, starting, checking
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
            .flatMap { [weak self] _ -> AnyPublisher<State, Error> in
                guard let self = self else {
                    return Future { $0(.success(State.starting)) }
                        .eraseToAnyPublisher()
                }
                return self.writeDefaults(defaults: defaults)
                    .flatMap { [weak self] _ -> AnyPublisher<State, Error> in
                        guard let self = self else {
                            return Future { $0(.success(State.starting)) }
                                .eraseToAnyPublisher()
                        }
                        return self.startApp()
                            .setFailureType(to: Swift.Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch { [weak self] error -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Future { $0(.success(State.starting)) }
                        .eraseToAnyPublisher()
                }
                return self.checkApp(upstreamError: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        Publishers.Merge(Just(.installing), command)
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
            .flatMap { [weak self] _ -> AnyPublisher<State, Error> in
                guard let self = self else {
                    return Future { $0(.success(State.starting)) }
                        .eraseToAnyPublisher()
                }
                return self.checkApp(upstreamError: nil)
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }
            .catch { [weak self] error -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Future { $0(.success(State.starting)) }
                        .eraseToAnyPublisher()
                }
                return self.checkApp(upstreamError: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return Publishers.Merge(Just(.starting), command)
            .eraseToAnyPublisher()
    }

    private func checkApp(upstreamError: Error?) -> AnyPublisher<State, Never> {
        let command = commander.run(command: ReadDefaultsCommand(id: simulatorId, bundleId: bundleId))
            .map { State.installed(error: upstreamError, defaults: $0) }
            .catch { Just(.notInstalled($0)) }
        return Publishers.Merge(Just(.checking), command)
            .eraseToAnyPublisher()
    }

    private func writeDefaults(defaults: Defaults?) -> AnyPublisher<Void, Error> {
        guard let defaults = defaults else {
            return Future { $0(.success(())) }
                .eraseToAnyPublisher()
        }

        return commander.run(command: WriteDefaultsCommand(id: simulatorId, bundleId: bundleId, defaults: defaults))
    }
}

extension IOSAppManager.State: Equatable {
    public static func == (lhs: IOSAppManager.State, rhs: IOSAppManager.State) -> Bool {
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
    public extension IOSAppManager {
        static func preview(state: State = .notInstalled(nil)) -> IOSAppManager {
            let manager = IOSAppManager(simulatorId: "test", bundleId: "test")
            manager.state = state
            return manager
        }

        func set(state: State) {
            self.state = state
        }
    }
#endif
