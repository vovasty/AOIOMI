//
//  PathMatcherTests.swift
//
//
//  Created by vlsolome on 2/7/21.
//

@testable import Translator
import XCTest

final class PathMatcherTests: XCTestCase {
    func testLesser() throws {
        let matcher = PathMatcher(paths: [["a", "b", "c"]])

        XCTAssertEqual(matcher.match(path: ["a", "b"]), .lesser)
    }

    func testEqual() throws {
        let matcher = PathMatcher(paths: [["a", "b", "c"]])

        XCTAssertEqual(matcher.match(path: ["a", "b", "c"]), .match)
    }

    func testGreater() throws {
        let matcher = PathMatcher(paths: [["a", "b", "c"]])

        XCTAssertEqual(matcher.match(path: ["a", "b", "c", "d"]), .match)
    }

    func testAsterisk() throws {
        let matcher = PathMatcher(paths: [["a", "*", "c"]])

        XCTAssertEqual(matcher.match(path: ["a", "b", "c", "d"]), .match)
    }

    func testNoMatch() throws {
        let matcher = PathMatcher(paths: [["a", "b", "c"]])

        XCTAssertEqual(matcher.match(path: ["a", "e", "c", "d"]), .noMatch)
    }

    func testEmpty() throws {
        let matcher = PathMatcher(paths: [["*"]])

        XCTAssertEqual(matcher.match(path: []), .match)
    }

    func testMultiple() throws {
        let matcher = PathMatcher(paths: [["a"], ["b"]])

        XCTAssertEqual(matcher.match(path: ["a"]), .match)
        XCTAssertEqual(matcher.match(path: ["b", "c"]), .match)
        XCTAssertEqual(matcher.match(path: ["d"]), .noMatch)
    }
}
