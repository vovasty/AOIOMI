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
        case notInstalled(Error?), installed(error: Error?, dataPath: URL?, defaults: Any?), installing, starting
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

    public init(simulatorId: String, bundleId: String) {
        self.simulatorId = simulatorId
        self.bundleId = bundleId
        commander = Commander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!)
    }

    public func install(app: URL, defaults: Defaults? = nil) {
        DispatchQueue.main.async {
            self.state = .installing
        }
        let command = InstallAppCommand(id: simulatorId, path: app)
        commander.run(command: command)
            .map { State.installed(error: nil, dataPath: nil, defaults: nil) }
            .catch { Just(State.notInstalled($0)) }
            .flatMap { state -> AnyPublisher<State, Never> in
                switch state {
                case .installed:
                    return self.checkAppState()
                        .map { State.installed(error: nil, dataPath: $0.dataPath, defaults: $0.defaults) }
                        .catch { Just(State.notInstalled($0)) }
                        .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                            guard let self = self else {
                                return Just(state)
                                    .eraseToAnyPublisher()
                            }

                            switch state {
                            case let .installed(error, dataPath, def):
                                guard let defaultsToWrite = defaults else {
                                    return Just(State.installed(error: error, dataPath: dataPath, defaults: defaults))
                                        .eraseToAnyPublisher()
                                }
                                return self.writeDefaults(defaults: defaultsToWrite, dataPath: dataPath)
                                    .map { State.installed(error: error, dataPath: dataPath, defaults: def) }
                                    .catch {
                                        Just(.installed(error: $0, dataPath: dataPath, defaults: def))
                                    }
                                    .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                                        guard let self = self else {
                                            return Just(state)
                                                .eraseToAnyPublisher()
                                        }
                                        switch state {
                                        case let .installed(_, dataPath, def):
                                            return self.startApp()
                                                .map { state }
                                                .catch {
                                                    Just(.installed(error: $0, dataPath: dataPath, defaults: def))
                                                }
                                                .eraseToAnyPublisher()
                                        default:
                                            return Just(state)
                                                .eraseToAnyPublisher()
                                        }
                                    }
                                    .eraseToAnyPublisher()
                            default:
                                return Just(state)
                                    .eraseToAnyPublisher()
                            }
                        }
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

    public func check() {
        checkAppState()
            .map { State.installed(error: nil, dataPath: $0.dataPath, defaults: $0.defaults) }
            .catch { _ in Just(.notInstalled(nil)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func checkAppState() -> AnyPublisher<(dataPath: URL?, defaults: Any?), Error> {
        commander.run(command: GetAppContainerPathCommand(id: simulatorId, bundleId: bundleId, type: .data))
            .tryMap {
                (dataPath: $0, defaults: try self.readDefaults(containerPath: $0))
            }
            .eraseToAnyPublisher()
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
                case let .installed(_, dataPath, defaults):
                    state = .installed(error: error, dataPath: dataPath, defaults: defaults)
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

    private func startApp() -> AnyPublisher<Void, Error> {
        let command = RunAppCommand(id: simulatorId, bundleId: bundleId)
        SimulatorApp.shared.open()
        return commander.run(command: command)
            .eraseToAnyPublisher()
    }

    private func readDefaults(containerPath: URL) throws -> Any {
        let url = containerPath
            .appendingPathComponent("Library")
            .appendingPathComponent("Preferences")
            .appendingPathComponent("\(bundleId).plist")

        let data = try Data(contentsOf: url)

        return try PropertyListSerialization.propertyList(from: data,
                                                          options: .mutableContainersAndLeaves,
                                                          format: nil)
    }

    private func writeDefaults(defaults: Defaults, dataPath: URL?) -> AnyPublisher<Void, Error> {
        guard let dataPath = dataPath else {
            return Fail(error: AppManagerError.wrongPath)
                .eraseToAnyPublisher()
        }
        let defaultsFile = dataPath
            .appendingPathComponent("Library")
            .appendingPathComponent("Preferences")
            .appendingPathComponent("\(bundleId).plist")

        return Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                do {
                    try self.write(defaults: defaults, path: defaultsFile)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func write(defaults: Defaults, path: URL) throws {
        var defaultsDict: [AnyHashable: Any]
        if FileManager.default.isReadableFile(atPath: path.path) {
            let inputData = try Data(contentsOf: path)
            guard let dict = try PropertyListSerialization.propertyList(from: inputData,
                                                                        options: .mutableContainersAndLeaves,
                                                                        format: nil) as? [AnyHashable: Any]
            else {
                throw AppManagerError.wrongFormat
            }
            defaultsDict = dict
        } else {
            defaultsDict = [:]
        }

        update(dictionary: &defaultsDict, at: defaults.path, with: defaults.data)
        let ouputData = try PropertyListSerialization.data(fromPropertyList: defaultsDict, format: .xml, options: 0)
        try ouputData.write(to: path)
    }

    // https://stackoverflow.com/a/55284347
    private func update(dictionary dict: inout [AnyHashable: Any], at keys: [AnyHashable], with value: Any) {
        if keys.count < 2 {
            for key in keys { dict[key] = value }
            return
        }

        var levels: [[AnyHashable: Any]] = []

        for key in keys.dropLast() {
            if let lastLevel = levels.last {
                if let currentLevel = lastLevel[key] as? [AnyHashable: Any] {
                    levels.append(currentLevel)
                } else if lastLevel[key] != nil, levels.count + 1 != keys.count {
                    break
                } else { return }
            } else {
                if let firstLevel = dict[keys[0]] as? [AnyHashable: Any] {
                    levels.append(firstLevel)
                } else { return }
            }
        }

        if levels[levels.indices.last!][keys.last!] != nil {
            levels[levels.indices.last!][keys.last!] = value
        } else { return }

        for index in levels.indices.dropLast().reversed() {
            levels[index][keys[index + 1]] = levels[index + 1]
        }

        dict[keys[0]] = levels[0]
    }
}

#if DEBUG
    public extension AppManager {
        static func preview(state: State = .notInstalled(nil)) -> AppManager {
            let manager = AppManager(simulatorId: "test", bundleId: "test")
            manager.state = state
            return manager
        }
    }
#endif
