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

extension AppManager: TestObjectProtocol {
    var statePublisher: Published<State>.Publisher {
        $state
    }
}

final class AppManagerTests: StatesTestCase<AppManager> {
    let simulatorName = "Test.Simulator"
    let bundleName = "test.test"

    override func getTestObject(commanderMock: CommanderMock) -> AppManager {
        AppManager(simulatorId: simulatorName, bundleId: bundleName, commander: commanderMock)
    }

    func testCheckFailure() throws {
        testStates([],
                   expected: [.notInstalled(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.check()
        }
    }

    func testCheckNoDefaultsSuccess() throws {
        let containerURL = URL(fileURLWithPath: "/nonexisting")

        testStates([CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                   expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: nil)]) {
            $0.check()
        }
    }

    func testCheckSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates([CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                   expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.check()
        }
    }

    func testStartFailure() throws {
        testStates([],
                   expected: [.notInstalled(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartPartialSuccess() throws {
        testStates([CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: [])],
                   expected: [.notInstalled(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates([
            CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: []),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
        ],
        expected: [.notInstalled(nil), .starting(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.start()
        }
    }

    func testInstallFailure() throws {
        testStates([],
                   expected: [.notInstalled(nil), .installing(nil), .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallDefaultsFailure() throws {
        testStates([CommanderMock.AllowedCommand(type: InstallAppCommand.self, stdout: [])],
                   expected: [.notInstalled(nil), .installing(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallStartFailure() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates([
            CommanderMock.AllowedCommand(type: InstallAppCommand.self, stdout: []),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
        ],
        expected: [.notInstalled(nil), .installing(nil), .starting(nil), .checking, .installed(error: CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand, defaults: ["some": "string"])]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallStartSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testStates([
            CommanderMock.AllowedCommand(type: InstallAppCommand.self, stdout: []),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
            CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: []),
        ],
        expected: [.notInstalled(nil), .installing(nil), .starting(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }
}
