@testable import AOSEmulator
import CommandPublisherMock
import CommonTests
import XCTest

extension AppManager: TestObjectProtocol {
    public var statePublisher: Published<State>.Publisher {
        $state
    }
}

final class AppManagerTests: XCTestCase, StatesTestCase {
    func getTestObject(commanderMock: CommanderMock) -> AppManager {
        let preferencesPath = Bundle.module.url(forResource: "Resources/test.xml", withExtension: nil)!.path

        return AppManager(activityId: "test.activity", packageId: "test.package", preferencesPath: preferencesPath, commander: commanderMock)
    }

    func testCheckFailure() throws {
        testStates(expected: [.notInstalled(nil), .checking, .notInstalled(nil)]) {
            $0.check()
        }
    }

    func testCheckDefaultsFailure() throws {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: IsAppInstalledCommand.self)],
                   expected: [.notInstalled(nil), .checking, .installed(error: CommanderMock.CommanderMockError.disallowedCommand, defaults: nil)]) {
            $0.check()
        }
    }

    func testCheckSuccess() throws {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: IsAppInstalledCommand.self), CommanderMock.AllowedCommand(type: GetAppPreferencesCommand.self)],
                   expected: [.notInstalled(nil), .checking, .installed(error: CommanderMock.CommanderMockError.disallowedCommand, defaults: nil)]) {
            $0.check()
        }
    }

    func testStartAppFailure() {
        testStates(expected: [.notInstalled(nil), .starting, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.start()
        }
    }

    func testStartAppStartSuccess() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: StartAppCommand.self)],
                   expected: [.notInstalled(nil), .starting, .checking, .notInstalled(nil)]) {
            $0.start()
        }
    }

    func testStartAppSuccess() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: StartAppCommand.self), CommanderMock.AllowedCommand(type: IsAppInstalledCommand.self), CommanderMock.AllowedCommand(type: GetAppPreferencesCommand.self)],
                   expected: [.notInstalled(nil), .starting, .checking, .installed(error: CommanderMock.CommanderMockError.disallowedCommand, defaults: nil)]) {
            $0.start()
        }
    }

    func testInstallFailure() {
        testStates(expected: [.notInstalled(nil), .installing, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(apk: URL(fileURLWithPath: "/nonexisting"))
        }
    }

    func testInstallStartFailure() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: InstallAPKCommand.self)],
                   expected: [.notInstalled(nil), .installing, .starting, .checking, .notInstalled(CommanderMock.CommanderMockError.disallowedCommand)]) {
            $0.install(apk: URL(fileURLWithPath: "/nonexisting"))
        }
    }

    func testInstallCheckFailure() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: InstallAPKCommand.self), CommanderMock.AllowedCommand(type: StartAppCommand.self)],
                   expected: [.notInstalled(nil), .installing, .starting, .checking, .notInstalled(nil)]) {
            $0.install(apk: URL(fileURLWithPath: "/nonexisting"))
        }
    }

    func testInstallSuccess() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: InstallAPKCommand.self), CommanderMock.AllowedCommand(type: StartAppCommand.self), CommanderMock.AllowedCommand(type: IsAppInstalledCommand.self)],
                   expected: [.notInstalled(nil), .installing, .starting, .checking, .installed(error: CommanderMock.CommanderMockError.disallowedCommand, defaults: nil)]) {
            $0.install(apk: URL(fileURLWithPath: "/nonexisting"))
        }
    }
}
