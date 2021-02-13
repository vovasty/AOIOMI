@testable import HTTPProxyManager
import XCTest

final class HTTPProxyManagerTests: XCTestCase {
    func testDefaults() {
        let manager = HTTPProxyManager()
        let ios = manager.proxy(type: .ios)

        XCTAssertEqual(ios?.host, "127.0.0.1")
        XCTAssertEqual(ios?.port, 8888)

        let aos = manager.proxy(type: .aos)

        XCTAssertEqual(aos?.host, "10.0.2.2")
        XCTAssertEqual(aos?.port, 8888)

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
        let manager = HTTPProxyManager(caURL: nil, settingsURL: nil)
        XCTAssertNil(manager.caURL)
    }

    func testExistingCA() {
        guard let caURL = Bundle.module.url(forResource: "Resources/ca", withExtension: "pem") else {
            XCTFail()
            return
        }
        let manager = HTTPProxyManager(caURL: caURL, settingsURL: nil)
        XCTAssertNotNil(manager.caURL)
    }

    func testNonExistingCA() {
        let caURL = URL(fileURLWithPath: "/none")
        let manager = HTTPProxyManager(caURL: caURL, settingsURL: nil)
        XCTAssertNil(manager.caURL)
    }

    func testNilConfig() {
        let manager = HTTPProxyManager(caURL: nil, settingsURL: nil)
        XCTAssertNil(manager.proxy(type: .ios))
        XCTAssertNil(manager.proxy(type: .aos))
    }

    func testNonExisingConfig() {
        let manager = HTTPProxyManager(caURL: nil, settingsURL: URL(fileURLWithPath: "/none"))
        XCTAssertNil(manager.proxy(type: .ios))
        XCTAssertNil(manager.proxy(type: .aos))
    }

    func testExistingConfig() {
        guard let settingsURL = Bundle.module.url(forResource: "Resources/config", withExtension: "config") else {
            XCTFail()
            return
        }
        let manager = HTTPProxyManager(caURL: nil, settingsURL: settingsURL)

        let ios = manager.proxy(type: .ios)

        XCTAssertEqual(ios?.host, "127.0.0.1")
        XCTAssertEqual(ios?.port, 8888)

        let aos = manager.proxy(type: .aos)

        XCTAssertEqual(aos?.host, "10.0.2.2")
        XCTAssertEqual(aos?.port, 8888)
    }

    func testJunkConfig() {
        guard let settingsURL = Bundle.module.url(forResource: "Resources/ca", withExtension: "pem") else {
            XCTFail()
            return
        }

        let manager = HTTPProxyManager(caURL: nil, settingsURL: settingsURL)
        XCTAssertNil(manager.proxy(type: .ios))
        XCTAssertNil(manager.proxy(type: .aos))
    }
}
