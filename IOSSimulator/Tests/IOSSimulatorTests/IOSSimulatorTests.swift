//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import CommandPublisherMock
import CommonTests
@testable import IOSSimulator
import XCTest

extension IOSSimulator: TestObjectProtocol {
    public var statePublisher: Published<State>.Publisher {
        $state
    }
}

final class IOSSimulatorTests: StatesTestCase<IOSSimulator> {
    let simulatorName = "Test.Simulator"

    override func getTestObject(commanderMock: CommanderMock) -> IOSSimulator {
        IOSSimulator(simulatorName: simulatorName, commander: commanderMock)
    }

    func testStartFailure() throws {
        testStates([],
                   expected: [.stopped(nil), .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.start() })
    }

    func testStartSuccess() throws {
        testStates([CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: [])],
                   expected: [.stopped(nil), .starting, .started],
                   action: { $0.start() })
    }

    func testStopSuccess() throws {
        testStates([CommanderMock.AllowedCommand(type: ShutdownSimulatorCommand.self, stdout: [])],
                   expected: [.stopped(nil), .stopping, .stopped(nil)],
                   action: { $0.stop() })
    }

    func testStopFailure() throws {
        testStates([],
                   expected: [.stopped(nil), .stopping, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.stop() })
    }

    func testCheckFailure() {
        testStates([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [])],
                   expected: [.stopped(nil), .checking, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.check() })
    }

    func testCheckStopped() throws {
        let stdout = try setDevice(state: .shutdown)

        testStates([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                   expected: [.stopped(nil), .checking, .stopped(nil)],
                   action: { $0.check() })
    }

    func testCheckStared() throws {
        let stdout = try setDevice(state: .booted)

        testStates([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                   expected: [.stopped(nil), .checking, .started],
                   action: { $0.check() })
    }

    func testCheckMalformed() throws {
        let stdout = try setDevice(state: .unknown("junk"))

        testStates([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                   expected: [.stopped(nil), .checking, .notConfigured(nil)],
                   action: { $0.check() })
    }

    func testCheckMissing() throws {
        let stdout = try setDevice(state: .unknown("junk"))
        var list = try JSONDecoder().decode(fileName: "list.json", type: SimctlList.self)
        list.devices = [:]

        testStates([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                   expected: [.stopped(nil), .checking, .notConfigured(nil)],
                   action: { $0.check() })
    }

    func testConfigureFailure() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        testStates([],
                   expected: [.stopped(nil), .configuring, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })
        testStates([],
                   expected: [.stopped(nil), .configuring, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }

    func testConfigureStartFailure() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        let uuid = "123456789"

        testStates([CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid])],
                   expected: [.stopped(nil), .configuring, .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })
        testStates([CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid])],
                   expected: [.stopped(nil), .configuring, .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }

    func testConfigureStartSuccess() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        let uuid = "123456789"

        testStates([
            CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid]),
            CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: []),
        ],
        expected: [.stopped(nil), .configuring, .starting, .started],
        action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })

        testStates([
            CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid]),
            CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: []),
        ],
        expected: [.stopped(nil), .configuring, .starting, .started],
        action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }
}

extension IOSSimulatorTests {
    private func setDevice(state: SimctlList.DeviceState) throws -> String {
        var list = try JSONDecoder().decode(fileName: "list.json", type: SimctlList.self)
        var newDevices = [String: [SimctlList.Device]]()

        for device in list.devices {
            guard var desired = device.value.first(where: { $0.name == simulatorName }) else {
                newDevices[device.key] = device.value
                continue
            }
            let remaining = device.value.filter { $0.name != simulatorName }
            desired.state = state
            newDevices[device.key] = remaining + [desired]
        }
        list.devices = newDevices
        return try JSONEncoder().toString(list)
    }
}
