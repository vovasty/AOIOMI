//
//  SwiftUIView.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import CommandPublisher
import SwiftShell
import SwiftUI

public class AppManager: ObservableObject {
    public enum State {
        case notInstalled(Error?), installed, installing, starting
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
    private let helperPath: URL
    private let context = CustomContext(main)
    private var cancellables: [AnyCancellable] = []
    private var dataPath: URL?
    private var defaults: Defaults?

    public init(simulatorId: String, bundleId: String, defaults: Defaults? = nil) {
        self.simulatorId = simulatorId
        self.bundleId = bundleId
        self.defaults = defaults
        helperPath = Bundle.module.url(forResource: "helper", withExtension: "sh")!
    }

    public func install(app: URL) {
        state = .installing
        let command = InstallAppCommand(id: simulatorId, path: app)
        command.run(helperPath: helperPath, context: context)
            .map { State.installing }
            .flatMap { state -> AnyPublisher<State, Error> in
                switch state {
                case .notInstalled:
                    return Future<State, Error> { promise in
                        promise(.success(state))
                    }
                    .eraseToAnyPublisher()
                default:
                    return self.checkAppState()
                        .flatMap { [weak self] state -> AnyPublisher<State, Error> in
                            guard let self = self else {
                                return Future<State, Error> { promise in
                                    promise(.success(state))
                                }
                                .eraseToAnyPublisher()
                            }

                            switch state {
                            case .notInstalled:
                                return Future<State, Error> { promise in
                                    promise(.success(state))
                                }
                                .eraseToAnyPublisher()
                            default:
                                return self.writeDefaults()
                                    .map { .installed }
                                    .eraseToAnyPublisher()
                            }
                        }
                        .eraseToAnyPublisher()
                }
            }
            .catch { Just(State.notInstalled($0)) }
            .collect()
            .map { $0.last ?? .notInstalled(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        checkAppState()
            .catch { error in Just(.notInstalled(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func checkAppState() -> AnyPublisher<State, Error> {
        let command = GetAppContainerPathCommand(id: simulatorId, bundleId: bundleId, type: .data)
        return command.run(helperPath: helperPath, context: context)
            .map { [weak self] in
                self?.dataPath = $0
                return .installed
            }
            .eraseToAnyPublisher()
    }

    public func start() {
        state = .starting
        let command = RunAppcommand(id: simulatorId, bundleId: bundleId)
        command.run(helperPath: helperPath, context: context)
            .map { _ in .installed }
            .catch { error in Just(.notInstalled(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func writeDefaults() -> AnyPublisher<Void, Error> {
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
            guard let defaults = self.defaults else {
                promise(.success(()))
                return
            }

            DispatchQueue.global(qos: .background).async {
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
