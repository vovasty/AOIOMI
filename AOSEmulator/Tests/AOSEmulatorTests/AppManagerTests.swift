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
                   expected: [.notInstalled(nil), .checking, .installed(error: nil, defaults: nil)]) {
            $0.check()
        }
    }
    
}
