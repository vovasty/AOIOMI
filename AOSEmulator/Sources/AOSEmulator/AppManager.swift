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

    public init(activityId: String, packageId: String, preferencesPath: String) {
        self.activityId = activityId
        self.packageId = packageId
        self.preferencesPath = preferencesPath
        commander = Commander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!)
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
        state = .checking
        checkAppState()
            .replaceError(with: .notInstalled(nil))
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func install(apk: URL) {
        state = .installing
        commander.run(command: InstallAPKCommand(apk: apk))
            .map { State.installed(error: nil, defaults: nil) }
            .catch { Just(.notInstalled($0)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func startApp() -> AnyPublisher<Void, Error> {
        commander.run(command: StartAppCommand(activityId: activityId))
            .eraseToAnyPublisher()
    }

    private func checkAppState() -> AnyPublisher<State, Error> {
        commander.run(command: IsAppInstalledCommand(packageId: packageId))
            .map { _ -> State in .installed(error: nil, defaults: nil) }
            .flatMap { [weak self] state -> AnyPublisher<State, Error> in
                guard let self = self else {
                    return Future { $0(.success(state)) }
                        .eraseToAnyPublisher()
                }
                switch state {
                case let .installed(error, _):
                    return self.commander.run(command: GetAppPreferencesCommand(preferencesPath: self.preferencesPath))
                        .map { xml -> State in .installed(error: error, defaults: xml) }
                        // just ignore this error
                        .catch { error in Future { $0(.success(.installed(error: error, defaults: nil))) }}
                        .eraseToAnyPublisher()
                default:
                    return Future { $0(.success(state)) }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
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
