@testable import MITMProxy
import XCTest

private func temporaryFileURL() -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                    isDirectory: true)

    let temporaryFilename = ProcessInfo().globallyUniqueString

    let temporaryFileURL =
        temporaryDirectoryURL.appendingPathComponent(temporaryFilename)

    return temporaryFileURL
}

private struct TestAddon: Addon {
    var id = "testId"
    var sysPath: String? = "testSysPath"
    var importString = "testImportString"
    var constructor = "testConstructor"
}

final class ProxyManagerTests: XCTestCase {
    private var tmpFile: URL!

    override func setUp() {
        super.setUp()
        tmpFile = temporaryFileURL()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpFile)
        super.tearDown()
    }

    func testScript() throws {
        let expected = """
        import sys
        sys.path.append('testSysPath')
        testImportString
        testId = testConstructor
        addons = [testId]
        """

        let manager = AddonManager(scriptURL: tmpFile)
        try manager.set(addons: [TestAddon()])
        let scriptData = try Data(contentsOf: tmpFile)
        let actual = String(data: scriptData, encoding: .utf8)
        XCTAssertEqual(expected, actual)
    }
}
