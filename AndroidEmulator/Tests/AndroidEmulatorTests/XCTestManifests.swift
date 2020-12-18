import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(AndroidEmulatorTests.allTests),
        ]
    }
#endif
