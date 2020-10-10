@testable import AndroidEmulator
import XCTest

final class AndroidEmulatorTests: XCTestCase {
    func testExample() {
        let x = AndroidEmulator()
        x.start()
        print("1")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
