@testable import UserDefaults
import XCTest

final class UserDefaultsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UserDefaults().text, "Hello, World!")
    }
}
