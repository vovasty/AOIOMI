import Combine
import CommandPublisher
import SwiftShell
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
    private let helperPath: URL
    private let context = CustomContext(main)
    private var cancellables: [AnyCancellable] = []

    public init(simulatorName: String) throws {
        self.simulatorName = simulatorName
        helperPath = Bundle.module.url(forResource: "helper", withExtension: "sh")!
    }

    public func start() {
        state = .starting
        let command = BootSimulatorCommand(id: simulatorName)
        command.run(helperPath: helperPath, context: context)
            .map { _ in .started }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func stop() {
        state = .starting
        let command = ShutdownSimulatorCommand(id: simulatorName)
        command.run(helperPath: helperPath, context: context)
            .map { _ in .stopped(nil) }
            .catch { error in Just(.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func configure(deviceType: SimctlList.DeviceType) {
        state = .configuring
        let command = CreateSimulatorCommand(name: simulatorName, deviceType: deviceType)
        command.run(helperPath: helperPath, context: context)
            .receive(on: DispatchQueue.main)
            .map { _ in .stopped(nil) }
            .catch { error in Just(.stopped(error)) }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    public func check() {
        state = .checking
        CheckSimulatorCommand(id: simulatorName).run(helperPath: helperPath, context: context)
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

        ListDeviceTypesCommand().run(helperPath: helperPath, context: context)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceTypes, on: self)
            .store(in: &cancellables)
    }
}
