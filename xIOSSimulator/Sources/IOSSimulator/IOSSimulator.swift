import Combine
import CommandPublisher
import SwiftUI

public class IOSSimulator: ObservableObject {
    enum Error: Swift.Error {
        case notCreated
    }

    public enum State {
        case stopped(Swift.Error?), started, starting, stopping, configuring, checking, notConfigured(Swift.Error?)
    }

    @Published public private(set) var state: State = .stopped(nil)
    @Published public private(set) var deviceTypes: [SimctlList.DeviceType] = []
    public private(set) var simulatorName: String
    private var cancellables = Set<AnyCancellable>()
    private let commander: Commander

    public convenience init(simulatorName: String) {
        self.init(simulatorName: simulatorName,
                  commander: ShellCommander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!))
    }

    init(simulatorName: String, commander: Commander) {
        self.simulatorName = simulatorName
        self.commander = commander
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                           object: nil, // always NSWorkspace
                           queue: OperationQueue.main) { [weak self] (notification: Notification) in
            guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
            guard app.bundleIdentifier == "com.apple.iphonesimulator" else { return }
            self?.state = .stopped(nil)
        }
    }

    public func start() {
        startSimulator()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func stop() {
        let publisher = commander.run(command: ShutdownSimulatorCommand(id: simulatorName))
            .map { _ in State.stopped(nil) }
            .catch { error in Just(.stopped(error)) }

        Publishers.Merge(Just(State.stopping), publisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func configure(deviceType: SimctlList.DeviceType, caURL: URL?) {
        let publisher = commander.run(command: CreateSimulatorCommand(name: simulatorName, deviceType: deviceType, caURL: caURL))
            .map { _ in State.stopped(nil) }
            .catch { error in Just(.notConfigured(error)) }

        Publishers.Merge(Just(State.configuring), publisher)
            .flatMap { [weak self] state -> AnyPublisher<State, Never> in
                guard let self = self else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
                switch state {
                case let .stopped(error):
                    if error != nil {
                        return Just(state)
                            .eraseToAnyPublisher()
                    }
                    return self.startSimulator()
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
        let publisher = commander.run(command: CheckSimulatorCommand(id: simulatorName))
            .map {
                switch $0 {
                case .shutdown:
                    return .stopped(nil)
                case .booted:
                    return .started
                case .notCreated:
                    return .notConfigured(nil)
                case .unknown:
                    return .notConfigured(nil)
                }
            }
            .catch { error in Just(State.notConfigured(error)) }
        Publishers.Merge(Just(State.checking), publisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)

        commander.run(command: ListDeviceTypesCommand())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceTypes, on: self)
            .store(in: &cancellables)
    }

    private func startSimulator() -> AnyPublisher<State, Never> {
        SimulatorApp.shared.open()
        let commandPublisher = commander.run(command: BootSimulatorCommand(id: simulatorName))
            .map { _ in State.started }
            .catch { error in Just(.stopped(error)) }
        return Publishers.Merge(Just(State.starting), commandPublisher)
            .eraseToAnyPublisher()
    }
}

extension IOSSimulator.State: Equatable {
    public static func == (lhs: IOSSimulator.State, rhs: IOSSimulator.State) -> Bool {
        switch (lhs, rhs) {
        case let (.stopped(r), .stopped(l)):
            return (r == nil && l == nil) || (r != nil && l != nil)
        case let (.notConfigured(r), .notConfigured(l)):
            return (r == nil && l == nil) || (r != nil && l != nil)
        case (.started, .started),
             (.starting, .starting),
             (.stopping, .stopping),
             (.configuring, .configuring),
             (.checking, .checking):
            return true
        default:
            return false
        }
    }
}

#if DEBUG
    public extension IOSSimulator {
        static func preview(state: State = .stopped(nil), deviceTypes: [SimctlList.DeviceType]? = nil) -> IOSSimulator {
            let simulator = IOSSimulator(simulatorName: "test")
            simulator.deviceTypes = deviceTypes ?? []
            simulator.state = state
            return simulator
        }
    }
#endif
