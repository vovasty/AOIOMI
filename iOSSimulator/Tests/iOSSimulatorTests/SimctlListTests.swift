@testable import iOSSimulator
import XCTest

final class iOSSimulatorTests: XCTestCase {
    func testDeviceState() throws {
        let expected: [SimctlList.DeviceState] = [.shutdown, .booted, .unknown("junk")]
        let json = """
            [
                "Shutdown",
                "Booted",
                "junk"
            ]
        """
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }

        let decoder = JSONDecoder()
        let actual = try decoder.decode([SimctlList.DeviceState].self, from: data)

        XCTAssertEqual(actual, expected)
    }
}
