@testable import Translator
import XCTest

final class MacDictionaryTests: XCTestCase {
    func testDictionary() throws {
        let dictionary = try MacDictionary(name: "뉴에이스 영한사전 / 뉴에이스 한영사전")
        let terms = Set<String>(["마스크", "qwerasd"])
        let expected = Translator.TranslationResult(translated: ["마스크": "a flu(e) mask."], missing: ["qwerasd"])

        let actual = try dictionary.translate(terms: terms)
        XCTAssertEqual(expected, actual)
    }
}
