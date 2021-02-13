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
        case notInstalled(Swift.Error?), installed(XMLIndexer?), installing, checking
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
        state = .checking
        commander.run(command: StartAppCommand(activityId: activityId))
            .map { State.checking }
            .catch { error in Just(.notInstalled(error)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.checking)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.checkAppState()
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        state = .checking
        checkAppState()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func install(apk: URL) {
        state = .installing
        commander.run(command: InstallAPKCommand(apk: apk))
            .map { State.installing }
            .catch { Just(.notInstalled($0)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.checking)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.checkAppState()
                }
            }
            .collect()
            .map { $0.last ?? .notInstalled(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func checkAppState() -> AnyPublisher<State, Never> {
        commander.run(command: IsAppInstalledCommand(packageId: packageId))
            .map { _ -> State in .checking }
            .catch { _ in Just(.notInstalled(nil)) }
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(.checking)
                        .eraseToAnyPublisher()
                }
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.commander.run(command: GetAppPreferencesCommand(preferencesPath: self.preferencesPath))
                        .map { xml -> State in .installed(xml) }
                        .catch { _ in Just(.installed(nil)) }
                        .eraseToAnyPublisher()
                }
            }
            .collect()
            .map { $0.last ?? .notInstalled(nil) }
            .eraseToAnyPublisher()
    }
}
