@testable import LinksAddon
import XCTest

final class LinkTests: XCTestCase {
    func testParseOne() throws {
        let link = Link(id: "1", name: "1", template: "http://hello/{{bbb}}", parameters: [Link.Pair(id: "bbb", value: "111")])
        XCTAssertEqual(try link.url(), URL(string: "http://hello/111"))
    }
}
