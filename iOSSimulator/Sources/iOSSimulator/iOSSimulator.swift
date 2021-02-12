import Combine
import CommandPublisher
import SwiftShell
import SwiftUI

public class iOSSimulator: ObservableObject {
    enum Error: Swift.Error {
        case notCreated
    }

    public enum SimulatorState {
        case stopped(Swift.Error?), started, starting, stopping, configuring, checking, notConfigured
    }

    @Published public private(set) var simulatorState: SimulatorState = .stopped(nil)
    @Published public private(set) var deviceTypes: [SimctlList.DeviceType] = []
    @Published public private(set) var simulatorId: String?
    private let helperPath: URL
    private let context: Context & CommandRunning
    private var cancellables: [AnyCancellable] = []

    public init(simulatorId: String?) throws {
        self.simulatorId = simulatorId
        context = CustomContext(main)
        helperPath = Bundle.module.url(forResource: "helper", withExtension: "sh")!
    }

    public func start() {
        guard let simulatorId = simulatorId else {
            simulatorState = .notConfigured
            return
        }

        simulatorState = .starting
        let command = BootSimulatorCommand(id: simulatorId)
        run(command: command)
            .map { _ in .started }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.simulatorState, on: self)
            .store(in: &cancellables)
    }

    public func stop() {
        guard let simulatorId = simulatorId else {
            simulatorState = .notConfigured
            return
        }

        simulatorState = .starting
        let command = ShutdownSimulatorCommand(id: simulatorId)
        run(command: command)
            .map { _ in .stopped(nil) }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.simulatorState, on: self)
            .store(in: &cancellables)
    }

    public func configure(deviceType: SimctlList.DeviceType) {
        simulatorState = .configuring
        let command = CreateSimulatorCommand(name: "iOSSimulator_\(deviceType.name)", deviceType: deviceType)
        run(command: command)
            .receive(on: DispatchQueue.main)
            .map {
                self.simulatorId = $0
                return .stopped(nil)
            }
            .catch { error in Just(.stopped(error)) }
            .assign(to: \.simulatorState, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        simulatorState = .checking
        if let simulatorId = simulatorId {
            run(command: CheckSimulatorCommand(id: simulatorId))
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
                .catch { error in Just(SimulatorState.stopped(error)) }
                .receive(on: DispatchQueue.main)
                .assign(to: \.simulatorState, on: self)
                .store(in: &cancellables)
        } else {
            simulatorState = .notConfigured
        }

        run(command: ListDeviceTypesCommand())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceTypes, on: self)
            .store(in: &cancellables)
    }

    private func run<CommandType: Command>(command: CommandType) -> AnyPublisher<CommandType.Result, Swift.Error> {
        let executable: String
        switch command.executable {
        case .helper:
            executable = helperPath.path
        }
        return CommandPublisher(context: context,
                                command: executable,
                                parameters: command.parameters)
            .tryMap {
                try command.parse(output: $0.stdout.lines())
            }
            .eraseToAnyPublisher()
    }
}
