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

extension AppManager: TestObjectProtocol {
    public var statePublisher: Published<State>.Publisher {
        $state
    }
}

final class AppManagerTests: XCTestCase, StatesTestCase {
    let simulatorName = "Test.Simulator"
    let bundleName = "test.test"

    func getTestObject(commanderMock: CommanderMock) -> AppManager {
        AppManager(simulatorId: simulatorName, bundleId: bundleName, commander: commanderMock)
    }

    func testCheckFailure() throws {
        testStates(expected: [.notInstalled(nil), .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.check()
        }
    }

    func testCheckNoDefaultsSuccess() throws {
        let containerURL = URL(fileURLWithPath: "/nonexisting")

        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                   expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: nil)]) {
            $0.check()
        }
    }

    func testCheckSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                   expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.check()
        }
    }

    func testStartFailure() throws {
        testStates(expected: [.notInstalled(nil), .starting, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartPartialSuccess() throws {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: RunAppCommand.self)],
                   expected: [.notInstalled(nil), .starting, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates(allowedCommands: [
            CommanderMock.AllowedCommand(type: RunAppCommand.self),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
        ],
        expected: [.notInstalled(nil), .starting, .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.start()
        }
    }

    func testInstallFailure() throws {
        testStates(expected: [.notInstalled(nil), .installing, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallDefaultsFailure() throws {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: InstallAppCommand.self)],
                   expected: [.notInstalled(nil), .installing, .starting, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallStartFailure() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates(allowedCommands: [
            CommanderMock.AllowedCommand(type: InstallAppCommand.self),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
        ],
        expected: [.notInstalled(nil), .installing, .starting, .checking, .installed(error: CommanderMock.CommanderMockError.disallowedCommand, defaults: ["some": "string"])]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallStartSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates(allowedCommands: [
            CommanderMock.AllowedCommand(type: InstallAppCommand.self),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
            CommanderMock.AllowedCommand(type: RunAppCommand.self),
        ],
        expected: [.notInstalled(nil), .installing, .starting, .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }
}
