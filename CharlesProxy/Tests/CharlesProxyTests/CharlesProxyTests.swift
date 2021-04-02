@testable import CharlesProxy
import XCTest

final class CharlesProxyTests: XCTestCase {
    func testDefaults() {
        let manager = CharlesProxy()
        XCTAssertEqual(manager.port, 8888)

        guard let expectedCAURL = FileManager.default.urls(for: .applicationSupportDirectory,
                                                           in: .userDomainMask)
            .first?
            .appendingPathComponent("Charles")
            .appendingPathComponent("ca")
            .appendingPathComponent("charles-proxy-ssl-proxying-certificate.pem")
        else {
            XCTFail()
            return
        }

        XCTAssertEqual(manager.caURL, expectedCAURL)
    }

    func testNilCA() {
        let manager = CharlesProxy(caURL: nil, settingsURL: nil)
        XCTAssertNil(manager.caURL)
    }

    func testExistingCA() {
        guard let caURL = Bundle.module.url(forResource: "Resources/ca", withExtension: "pem") else {
            XCTFail()
            return
        }
        let manager = CharlesProxy(caURL: caURL, settingsURL: nil)
        XCTAssertNotNil(manager.caURL)
    }

    func testNonExistingCA() {
        let caURL = URL(fileURLWithPath: "/none")
        let manager = CharlesProxy(caURL: caURL, settingsURL: nil)
        XCTAssertNil(manager.caURL)
    }

    func testNilConfig() {
        let manager = CharlesProxy(caURL: nil, settingsURL: nil)
        XCTAssertNil(manager.port)
    }

    func testNonExisingConfig() {
        let manager = CharlesProxy(caURL: nil, settingsURL: URL(fileURLWithPath: "/none"))
        XCTAssertNil(manager.port)
    }

    func testExistingConfig() {
        guard let settingsURL = Bundle.module.url(forResource: "Resources/config", withExtension: "config") else {
            XCTFail()
            return
        }
        let manager = CharlesProxy(caURL: nil, settingsURL: settingsURL)

        XCTAssertEqual(manager.port, 8888)
    }

    func testJunkConfig() {
        guard let settingsURL = Bundle.module.url(forResource: "Resources/ca", withExtension: "pem") else {
            XCTFail()
            return
        }

        let manager = CharlesProxy(caURL: nil, settingsURL: settingsURL)
        XCTAssertNil(manager.port)
    }
}
