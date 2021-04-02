import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(HTTPProxyManagerTests.allTests),
        ]
    }
#endif
