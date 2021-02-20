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

public class AppManager: ObservableObject {
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
        let currentState = state
        DispatchQueue.main.async {
            self.state = .starting
        }
        startApp()
            .map { currentState }
            .catch { error -> AnyPublisher<State, Never> in
                let state: State
                switch currentState {
                case let .installed(_, defaults):
                    state = .installed(error: error, defaults: defaults)
                default:
                    state = currentState
                }
                return Just(state)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        checkAppState(upstreamError: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func install(apk: URL) {
        state = .installing
        commander.run(command: InstallAPKCommand(apk: apk))
            .map { State.installed(error: nil, defaults: nil) }
            .catch { Just(.notInstalled($0)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.startApp()
                        .map { State.installed(error: nil, defaults: nil) }
                        .replaceError(with: State.installed(error: nil, defaults: nil))
                        .catch { Just(.installed(error: $0, defaults: nil)) }
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startApp() -> AnyPublisher<Void, Error> {
        commander.run(command: StartAppCommand(activityId: activityId))
            .eraseToAnyPublisher()
    }

    private func checkAppState(upstreamError: Error?) -> AnyPublisher<State, Never> {
        let publisher = commander.run(command: IsAppInstalledCommand(packageId: packageId))
            .map { _ in State.installed(error: upstreamError, defaults: nil) }
            .catch { _ in Just(.notInstalled(nil)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
                switch state {
                case let .installed(error, _):
                    return self.commander.run(command: GetAppPreferencesCommand(preferencesPath: self.preferencesPath))
                        .map { xml -> State in .installed(error: error, defaults: xml) }
                        .replaceError(with: state)
                        .eraseToAnyPublisher()
                default:
                    return Future { $0(.success(state)) }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        
        return Publishers.Merge(Just(.checking), publisher)
            .eraseToAnyPublisher()

    }
}

extension AppManager.State: Equatable {
    public static func == (lhs: AppManager.State, rhs: AppManager.State) -> Bool {
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
    public extension AppManager {
        static func preview(state: State = .checking) -> AppManager {
            let manager = AppManager(activityId: "test", packageId: "test", preferencesPath: "test")
            manager.state = state
            return manager
        }
    }
#endif
