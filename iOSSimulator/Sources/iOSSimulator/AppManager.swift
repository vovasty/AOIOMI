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
        case notInstalled(Error?), installed(Error?), installing, starting
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
    private var dataPath: URL?
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
            .map { State.installing }
            .catch { Just(State.notInstalled($0)) }
            .flatMap { state -> AnyPublisher<State, Never> in
                switch state {
                case .installing:
                    return self.checkAppState()
                        .map { State.installing }
                        .catch { Just(State.notInstalled($0)) }
                        .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                            guard let self = self else {
                                return Just(state)
                                    .eraseToAnyPublisher()
                            }

                            switch state {
                            case .installing:
                                guard let defaults = defaults else {
                                    return Just(State.installed(nil))
                                        .eraseToAnyPublisher()
                                }
                                return self.writeDefaults(defaults: defaults)
                                    .map { .installed(nil) }
                                    .catch { Just(State.notInstalled($0)) }
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
            .catch { Just(State.notInstalled($0)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        checkAppState()
            .map { _ in State.installed(nil) }
            .catch { error in Just(.notInstalled(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func checkAppState() -> AnyPublisher<Void, Error> {
        let command = GetAppContainerPathCommand(id: simulatorId, bundleId: bundleId, type: .data)
        return commander.run(command: command)
            .map { [weak self] in
                self?.dataPath = $0
            }
            .eraseToAnyPublisher()
    }

    public func start() {
        DispatchQueue.main.async {
            self.state = .starting
        }
        let command = RunAppcommand(id: simulatorId, bundleId: bundleId)
        commander.run(command: command)
            .map { _ in .installed(nil) }
            .catch { error in Just(.notInstalled(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func writeDefaults(defaults: Defaults) -> AnyPublisher<Void, Error> {
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
