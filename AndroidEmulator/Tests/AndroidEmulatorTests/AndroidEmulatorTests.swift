@testable import AndroidEmulator
import XCTest

final class AndroidEmulatorTests: XCTestCase {
    func testExample() throws {
        let x = try AndroidEmulator()
        x.start()
        print("1")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
