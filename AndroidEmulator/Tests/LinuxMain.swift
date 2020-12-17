import XCTest

import AndroidEmulatorTests

var tests = [XCTestCaseEntry]()
tests += AndroidEmulatorTests.allTests()
XCTMain(tests)
