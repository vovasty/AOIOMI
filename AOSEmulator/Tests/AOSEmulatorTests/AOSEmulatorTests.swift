@testable import AOSEmulator
import XCTest

final class AOSEmulatorTests: XCTestCase {
    func testExample() throws {
        let x = AOSEmulator()
        x.start()
        print("1")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
