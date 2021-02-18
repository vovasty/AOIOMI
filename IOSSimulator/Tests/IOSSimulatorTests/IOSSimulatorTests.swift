//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Combine
import CommandPublisherMock
@testable import IOSSimulator
import XCTest

final class IOSSimulatorTests: XCTestCase {
    let simulatorName = "Test.Simulator"

    private func testSimulator(file: StaticString = #filePath, line: UInt = #line, _ allowedCommands: [CommanderMock.AllowedCommand], expected: [IOSSimulator.State], action: (IOSSimulator) -> Void) {
        let mock = CommanderMock(allowedCommands: allowedCommands)
        let simulator = IOSSimulator(simulatorName: simulatorName, commander: mock)
        var actual = [IOSSimulator.State]()
        var tokens = Set<AnyCancellable>()
        let e = expectation(description: "test")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // Change `2.0` to the desired number of seconds.
            e.fulfill()
        }
        simulator.$state
            .sink(receiveValue: {
                actual.append($0)
            })
            .store(in: &tokens)

        action(simulator)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(actual, expected, file: file, line: line)
    }

    func setDevice(state: SimctlList.DeviceState) throws -> String {
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

    func testStartFailure() throws {
        testSimulator([],
                      expected: [.stopped(nil), .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.start() })
    }

    func testStartSuccess() throws {
        testSimulator([CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: [])],
                      expected: [.stopped(nil), .starting, .started],
                      action: { $0.start() })
    }

    func testStopSuccess() throws {
        testSimulator([CommanderMock.AllowedCommand(type: ShutdownSimulatorCommand.self, stdout: [])],
                      expected: [.stopped(nil), .stopping, .stopped(nil)],
                      action: { $0.stop() })
    }

    func testStopFailure() throws {
        testSimulator([],
                      expected: [.stopped(nil), .stopping, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.stop() })
    }

    func testCheckFailure() {
        testSimulator([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [])],
                      expected: [.stopped(nil), .checking, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.check() })
    }

    func testCheckStopped() throws {
        let stdout = try setDevice(state: .shutdown)

        testSimulator([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                      expected: [.stopped(nil), .checking, .stopped(nil)],
                      action: { $0.check() })
    }

    func testCheckStared() throws {
        let stdout = try setDevice(state: .booted)

        testSimulator([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                      expected: [.stopped(nil), .checking, .started],
                      action: { $0.check() })
    }

    func testCheckMalformed() throws {
        let stdout = try setDevice(state: .unknown("junk"))

        testSimulator([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                      expected: [.stopped(nil), .checking, .notConfigured(nil)],
                      action: { $0.check() })
    }

    func testCheckMissing() throws {
        let stdout = try setDevice(state: .unknown("junk"))
        var list = try JSONDecoder().decode(fileName: "list.json", type: SimctlList.self)
        list.devices = [:]

        testSimulator([CommanderMock.AllowedCommand(type: CheckSimulatorCommand.self, stdout: [stdout])],
                      expected: [.stopped(nil), .checking, .notConfigured(nil)],
                      action: { $0.check() })
    }

    func testConfigureFailure() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        testSimulator([],
                      expected: [.stopped(nil), .configuring, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })
        testSimulator([],
                      expected: [.stopped(nil), .configuring, .notConfigured(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }

    func testConfigureStartFailure() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        let uuid = "123456789"

        testSimulator([CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid])],
                      expected: [.stopped(nil), .configuring, .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })
        testSimulator([CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid])],
                      expected: [.stopped(nil), .configuring, .starting, .stopped(CommanderMock.CommanderMockError.disallowedCommand)],
                      action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }

    func testConfigureStartSuccess() {
        guard let pemURL = Bundle.module.url(forResource: "Resources/test.pem", withExtension: nil) else {
            XCTFail()
            return
        }
        let uuid = "123456789"

        testSimulator([
            CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid]),
            CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: []),
        ],
        expected: [.stopped(nil), .configuring, .starting, .started],
        action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: pemURL) })

        testSimulator([
            CommanderMock.AllowedCommand(type: CreateSimulatorCommand.self, stdout: [uuid]),
            CommanderMock.AllowedCommand(type: BootSimulatorCommand.self, stdout: []),
        ],
        expected: [.stopped(nil), .configuring, .starting, .started],
        action: { $0.configure(deviceType: SimctlList.DeviceType(name: "test device"), caURL: nil) })
    }
}
