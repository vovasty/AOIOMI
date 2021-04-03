//
//  TermReplacerTests.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation

@testable import Translator
import XCTest

final class TermReplacerTests: XCTestCase {
    func testString() {
        let input = "string"
        let terms = ["string": "translated"]
        let expected = "translated"

        let pathMatcher = PathMatcher(paths: [["*"]])
        let replacer = TermReplacer(pathMatcher: pathMatcher)
        let actual = replacer.replace(terms: terms, any: input)

        XCTAssertEqual(expected, actual as? String)
    }

    func testArray() {
        let input: [Any] = ["string", 1, true]
        let terms = ["string": "translated"]
        let expected: [Any] = ["translated", 1, true]

        let pathMatcher = PathMatcher(paths: [["*"]])
        let replacer = TermReplacer(pathMatcher: pathMatcher)
        guard let actual = replacer.replace(terms: terms, any: input) as? [Any] else { XCTFail(); return }

        XCTAssert(NSArray(array: actual).isEqual(to: expected))
    }

    func testDictionary() {
        let input: [String: Any] = ["string": "string", "number": 1, "boolean": true]
        let terms = ["string": "translated"]
        let expected: [String: Any] = ["string": "translated", "number": 1, "boolean": true]

        let pathMatcher = PathMatcher(paths: [["*"]])
        let replacer = TermReplacer(pathMatcher: pathMatcher)

        guard let actual = replacer.replace(terms: terms, any: input) as? [String: Any] else { XCTFail(); return }

        XCTAssert(NSDictionary(dictionary: actual).isEqual(to: expected))
    }

    func testMixed() {
        let input: [String: Any] = ["string": "string1",
                                    "array": ["some", "string2", ["a": "b", "string": "string3"]]]
        let terms = ["string1": "translated1", "string2": "translated2", "string3": "translated3"]
        let expected: [String: Any] = ["string": "translated1",
                                       "array": ["some", "translated2", ["a": "b", "string": "translated3"]]]

        let pathMatcher = PathMatcher(paths: [["*"]])
        let replacer = TermReplacer(pathMatcher: pathMatcher)
        guard let actual = replacer.replace(terms: terms, any: input) as? [String: Any] else { XCTFail(); return }

        XCTAssert(NSDictionary(dictionary: actual).isEqual(to: expected))
    }

    func testMixedPath() {
        let input: [String: Any] = ["string": "string1",
                                    "array": ["some", "string2", ["a": "b", "string": "string3"]]]
        let terms = ["string1": "translated1", "string2": "translated2", "string3": "translated3"]
        let expected: [String: Any] = ["string": "string1",
                                       "array": ["some", "translated2", ["a": "b", "string": "string3"]]]

        let pathMatcher = PathMatcher(paths: [["array", "1"]])
        let replacer = TermReplacer(pathMatcher: pathMatcher)
        guard let actual = replacer.replace(terms: terms, any: input) as? [String: Any] else { XCTFail(); return }

        XCTAssert(NSDictionary(dictionary: actual).isEqual(to: expected))
    }
}
