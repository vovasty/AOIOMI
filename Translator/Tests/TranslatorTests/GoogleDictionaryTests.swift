@testable import Translator
import XCTest

final class GoogleDictionaryTests: XCTestCase {
    func testDictionary() throws {
        let dictionary = GoogleDictionary(fromLanguage: "ko", toLanguage: "en")
        let terms = ["마스크\n마스크", "abra\nkadabra"]
        let expected = ["마스크\n마스크": "Mask\nMask", "abra\nkadabra": "abra\nkadabra"]

        let actual = try dictionary.lookup(terms: terms)
        XCTAssertEqual(expected, actual)
    }
}
