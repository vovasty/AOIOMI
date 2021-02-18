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

final class AppManagerTests: XCTestCase {
    let simulatorName = "Test.Simulator"
    let bundleName = "test.test"

    private func testManager(file: StaticString = #filePath, line: UInt = #line, _ allowedCommands: [CommanderMock.AllowedCommand], expected: [AppManager.State], action: (AppManager) -> Void) {
        let mock = CommanderMock(allowedCommands: allowedCommands)
        let manager = AppManager(simulatorId: simulatorName, bundleId: bundleName, commander: mock)
        var actual = [AppManager.State]()
        var tokens = Set<AnyCancellable>()
        let e = expectation(description: "test")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // Change `2.0` to the desired number of seconds.
            e.fulfill()
        }
        manager.$state
            .sink(receiveValue: {
                actual.append($0)
            })
            .store(in: &tokens)

        action(manager)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(actual, expected, file: file, line: line)
    }

    //    commander.run(command: GetAppContainerPathCommand(id: simulatorId, bundleId: bundleId, type: .data))

    func testCheckFailure() throws {
        testManager([],
                    expected: [.notInstalled(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.check()
        }
    }

    func testCheckNoDefaultsSuccess() throws {
        let containerURL = URL(fileURLWithPath: "/nonexisting")

        testManager([CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                    expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: nil)]) {
            $0.check()
        }
    }

    func testCheckSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testManager([CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path])],
                    expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.check()
        }
    }

    func testStartFailure() throws {
        testManager([],
                    expected: [.notInstalled(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartPartialSuccess() throws {
        testManager([CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: [])],
                    expected: [.notInstalled(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartSuccess() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testManager([
            CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: []),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
        ],
        expected: [.notInstalled(nil), .starting(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.start()
        }
    }

    func testInstallFailure() throws {
        testManager([],
                    expected: [.notInstalled(nil), .installing(nil), .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallDefaultsFailure() throws {
        testManager([CommanderMock.AllowedCommand(type: InstallAppCommand.self, stdout: [])],
                    expected: [.notInstalled(nil), .installing(nil), .starting(nil), .checking, .notInstalled(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }

    func testInstallStartFailure() throws {
        guard let containerURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            XCTFail()
            return
        }

        testManager([
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

        testManager([
            CommanderMock.AllowedCommand(type: InstallAppCommand.self, stdout: []),
            CommanderMock.AllowedCommand(type: ReadDefaultsCommand.self, stdout: [containerURL.path]),
            CommanderMock.AllowedCommand(type: RunAppCommand.self, stdout: []),
        ],
        expected: [.notInstalled(nil), .installing(nil), .starting(nil), .checking, .installed(error: nil, defaults: ["some": "string"])]) {
            $0.install(app: URL(fileURLWithPath: "/doesntmatter"), defaults: nil)
        }
    }
}
