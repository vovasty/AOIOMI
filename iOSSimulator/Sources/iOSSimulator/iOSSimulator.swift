import Combine
import CommandPublisher
import SwiftUI

public class iOSSimulator: ObservableObject {
    enum Error: Swift.Error {
        case notCreated
    }

    public enum State {
        case stopped(Swift.Error?), started, starting, stopping, configuring, checking, notConfigured
    }

    @Published public private(set) var state: State = .stopped(nil)
    @Published public private(set) var deviceTypes: [SimctlList.DeviceType] = []
    public private(set) var simulatorName: String
    private var cancellables = Set<AnyCancellable>()
    private let commander: Commander

    public init(simulatorName: String) throws {
        self.simulatorName = simulatorName
        commander = Commander(helperPath: Bundle.module.url(forResource: "helper", withExtension: "sh")!)
    }

    public func start() {
        state = .starting
        let command = BootSimulatorCommand(id: simulatorName)
        commander.run(command: command)
            .map { _ in .started }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        SimulatorApp.shared.open()
    }

    public func stop() {
        state = .starting
        let command = ShutdownSimulatorCommand(id: simulatorName)
        commander.run(command: command)
            .map { _ in .stopped(nil) }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func configure(deviceType: SimctlList.DeviceType) {
        state = .configuring
        let command = CreateSimulatorCommand(name: simulatorName, deviceType: deviceType)
        commander.run(command: command)
            .receive(on: DispatchQueue.main)
            .map { _ in .stopped(nil) }
            .catch { error in Just(.stopped(error)) }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        state = .checking
        commander.run(command: CheckSimulatorCommand(id: simulatorName))
            .map {
                switch $0 {
                case .shutdown:
                    return .stopped(nil)
                case .booted:
                    return .started
                case .notCreated:
                    return .notConfigured
                case .unknown:
                    return .notConfigured
                }
            }
            .catch { error in Just(State.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)

        commander.run(command: ListDeviceTypesCommand())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceTypes, on: self)
            .store(in: &cancellables)
    }
}
