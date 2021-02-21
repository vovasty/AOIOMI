@testable import AOSEmulator
import CommandPublisherMock
import CommonTests
import XCTest

extension AOSEmulator: TestObjectProtocol {
    public var statePublisher: Published<State>.Publisher {
        $state
    }
}

final class AOSEmulatorTests: XCTestCase, StatesTestCase {
    func getTestObject(commanderMock: CommanderMock) -> AOSEmulator {
        AOSEmulator(commander: commanderMock)
    }

    func testStartFailure() {
        testStates(expected: [.stopped(nil), .starting, .stopped(nil)],
                   action: { $0.start() })
    }

    func testStartWaitBootSuccess() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: WaitBootedCommand.self)],
                   expected: [.stopped(nil), .starting, .stopped(nil)],
                   action: { $0.start() })
    }

    func testStarAsyncSucceess() {
        testStates(allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand(type: StartEmulatorCommand.self)],
                   expected: [.stopped(nil), .starting, .stopped(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.start() })
    }

    func testStartSuccess() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: WaitBootedCommand.self)],
                   allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand(type: StartEmulatorCommand.self)],
                   expected: [.stopped(nil), .starting, .started],
                   action: { $0.start() })
    }

    func testCheckFailure() {
        testStates(expected: [.stopped(nil), .checking, .notConfigured(nil)],
                   action: { $0.check() })
    }

    func testCheckSucces() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: IsEmulatorCreatedCommand.self)],
                   expected: [.stopped(nil), .checking, .stopped(nil)],
                   action: { $0.check() })
    }

    func testConfigureCreateEmulatorCommandFailure() {
        testStates(expected: [.stopped(nil), .configuring, .notConfigured(CommandPublisherMock.CommanderMock.CommanderMockError.disallowedCommand)],
                   action: { $0.configure(proxy: nil, caPath: nil) })
    }

    func testConfigureStartFailure() {
        testStates(allowedCommands: [CommanderMock.AllowedCommand(type: CreateEmulatorCommand.self)],
                   expected: [.stopped(nil), .configuring, .starting, .stopped(nil)],
                   action: { $0.configure(proxy: nil, caPath: nil) })
    }

    func testConfigureSuccess() {
        testStates(allowedCommands: [
            CommanderMock.AllowedCommand(type: CreateEmulatorCommand.self),
            CommanderMock.AllowedCommand(type: WaitBootedCommand.self),
        ],
        allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand(type: StartEmulatorCommand.self)],
        expected: [.stopped(nil), .configuring, .starting, .started],
        action: { $0.configure(proxy: nil, caPath: nil) })
    }
}
