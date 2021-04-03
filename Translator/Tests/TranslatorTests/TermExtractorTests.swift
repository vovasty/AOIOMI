//
//  TermExtractorTests.swift
//
//
//  Created by vlsolome on 1/22/21.
//

@testable import Translator
import XCTest

final class TermExtractorTests: XCTestCase {
    func testDictionary() {
        let input: [String: Any] = ["a": "translatable a",
                                    "b": "translatable b",
                                    "stop": "stop key",
                                    "number": 1,
                                    "boolean": true,
                                    "value": "skip"]

        let expected = Set<String>(["translatable a", "translatable b"])

        let extractor = TermExtractor(skipKeys: Set<String>(["stop"])) {
            $0 != "skip"
        }

        let pathMatcher = PathMatcher(paths: [["*"]])

        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testArray() {
        let input: [Any] = ["translatable a",
                            "translatable b",
                            1,
                            true,
                            "skip"]

        let expected = Set<String>(["translatable a", "translatable b"])

        let extractor = TermExtractor(skipKeys: Set<String>()) {
            $0 != "skip"
        }
        let pathMatcher = PathMatcher(paths: [["*"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testSkipString() {
        let input = "skip"

        let expected = Set<String>()

        let extractor = TermExtractor(skipKeys: Set<String>()) {
            $0 != "skip"
        }
        let pathMatcher = PathMatcher(paths: [["*"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testString() {
        let input = "string"

        let expected = Set<String>(["string"])

        let extractor = TermExtractor(skipKeys: Set<String>()) { _ in
            true
        }
        let pathMatcher = PathMatcher(paths: [["*"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testMixed() {
        let input: [String: Any] = ["array": ["translatable a", "translatable b", "skip", 1, false],
                                    "dictionary": ["aa": "translatable aa", "b": "translatable bb"],
                                    "c": "translatable c",
                                    "stop": "stop key",
                                    "number": 1,
                                    "boolean": true,
                                    "value": "skip"]

        let expected = Set<String>(["translatable a", "translatable b", "translatable c", "translatable bb", "translatable aa"])

        let extractor = TermExtractor(skipKeys: Set<String>(["stop"])) {
            $0 != "skip"
        }

        let pathMatcher = PathMatcher(paths: [["*"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testMixedPath() {
        let input: [String: Any] = ["array": ["translatable a", "translatable b", "skip", 1, false],
                                    "dictionary": ["aa": "translatable aa", "b": "translatable bb"],
                                    "c": "translatable c",
                                    "stop": "stop key",
                                    "number": 1,
                                    "boolean": true,
                                    "value": "skip"]

        let expected = Set<String>(["translatable bb", "translatable aa"])

        let extractor = TermExtractor(skipKeys: Set<String>(["stop"])) {
            $0 != "skip"
        }

        let pathMatcher = PathMatcher(paths: [["dictionary"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }

    func testMixedMultiple() {
        let input: [String: Any] = ["array": [["x": "translate x"], ["y": "translate y"]],
                                    "dictionary": ["aa": "translatable aa", "b": "translatable bb"],
                                    "array1": [["x": "translate xx"], ["y": "translate yy"]],
                                    "c": "translatable c",
                                    "stop": "stop key",
                                    "number": 1,
                                    "boolean": true,
                                    "value": "skip"]

        let expected = Set<String>(["translate x", "translate xx"])

        let extractor = TermExtractor(skipKeys: Set<String>()) { _ in true }

        let pathMatcher = PathMatcher(paths: [["*", "*", "x"]])
        let actual = extractor.extract(terms: input, pathMatcher: pathMatcher)

        XCTAssertEqual(expected, actual)
    }
}
