//
//  File.swift
//
//
//  Created by vlsolome on 2/5/21.
//

@testable import Translator
import XCTest

private struct TestDictionary: Dictionary {
    func translate(terms: Set<String>) throws -> Translator.TranslationResult {
        let translated = terms
            .reduce([String: String]()) { dict, term -> [String: String] in
                var d = dict
                d[term] = term == "untranslated" ? "translated" : term
                return d
            }

        return Translator.TranslationResult(translated: translated,
                                            missing: Set<String>())
    }
}

private func serialize(_ object: Any) throws -> String {
    let encodedJSON = try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
    return String(data: encodedJSON, encoding: .utf8) ?? ""
}

final class TranslatorTests: XCTestCase {
    func testTranslate() throws {
        let input = try serialize(["a": ["b": ["d": ["untranslated", "other"]]]])
        let expected = try serialize(["a": ["b": ["d": ["translated", "other"]]]])
        let translator = try Translator(dictionaries: [TestDictionary()], skipKeys: Set<String>()) { _ in
            true
        }

        let actual = try translator.translate(json: input, path: ["a.b.d"])
        XCTAssertEqual(expected, actual)
    }
}
