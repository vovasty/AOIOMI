//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import Foundation

import Combine
import CommandPublisher
import SWXMLHash

public class AOSAppManager: ObservableObject {
    public enum State {
        case notInstalled(Swift.Error?), installed(error: Error?, defaults: XMLIndexer?), installing, checking, starting
    }

    @Published public private(set) var state: State = .notInstalled(nil)
    public let activityId: String
    public let packageId: String
    public let preferencesPath: String

    private var cancellables = Set<AnyCancellable>()
    private let commander: Commander

    public convenience init(activityId: String, packageId: String, preferencesPath: String) {
        self.init(activityId: activityId,
                  packageId: packageId,
                  preferencesPath: preferencesPath,
                  commander: ShellCommander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!))
    }

    init(activityId: String, packageId: String, preferencesPath: String, commander: Commander) {
        self.activityId = activityId
        self.packageId = packageId
        self.preferencesPath = preferencesPath
        self.commander = commander
    }

    public func start() {
        startApp()
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

    public func install(apk: URL) {
        let publisher = commander.run(command: InstallAPKCommand(apk: apk))
            .flatMap { [weak self] _ -> AnyPublisher<State, Error> in
                guard let self = self else {
                    return Future { $0(.success(State.installing)) }
                        .eraseToAnyPublisher()
                }
                return self.startApp()
                    .setFailureType(to: Error.self)
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

        return Publishers.Merge(Just(.installing), publisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startApp() -> AnyPublisher<State, Never> {
        let publisher = commander.run(command: StartAppCommand(activityId: activityId))
            .flatMap { [weak self] _ -> AnyPublisher<State, Swift.Error> in
                guard let self = self else {
                    return Future { $0(.success(State.checking)) }
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

        return Publishers.Merge(Just(.starting), publisher)
            .eraseToAnyPublisher()
    }

    private func checkApp(upstreamError: Error?) -> AnyPublisher<State, Never> {
        let publisher = commander.run(command: IsAppInstalledCommand(packageId: packageId))
            .flatMap { [weak self] _ -> AnyPublisher<State, Swift.Error> in
                guard let self = self else {
                    return Future { $0(.success(State.checking)) }
                        .eraseToAnyPublisher()
                }
                return self.commander.run(command: GetAppPreferencesCommand(preferencesPath: self.preferencesPath))
                    .map { xml -> State in .installed(error: upstreamError, defaults: xml) }
                    .catch { Just(.installed(error: $0, defaults: nil)) }
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }
            .replaceError(with: .notInstalled(upstreamError))
            .eraseToAnyPublisher()

        return Publishers.Merge(Just(.checking), publisher)
            .eraseToAnyPublisher()
    }
}

extension AOSAppManager.State: Equatable {
    public static func == (lhs: AOSAppManager.State, rhs: AOSAppManager.State) -> Bool {
        switch (lhs, rhs) {
        case let (.installed(re, rd), .installed(le, ld)):
            return ((re == nil && le == nil) || (re != nil && le != nil)) &&
                ((rd == nil && ld == nil) || (rd != nil && ld != nil))
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
    public extension AOSAppManager {
        static func preview(state: State = .checking) -> AOSAppManager {
            let manager = AOSAppManager(activityId: "test", packageId: "test", preferencesPath: "test")
            manager.state = state
            return manager
        }
    }
#endif
