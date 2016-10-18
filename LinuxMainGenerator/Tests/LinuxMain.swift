#if os(Linux)

import XCTest
@testable import LinuxMainGeneratorTests

    extension ATests {
        static let allTests = [
                ("test001",test001),
                ("test002",test002),
            ]
    }

    extension BTests {
        static let allTests = [
                ("test001",test001),
            ]
    }

    XCTMain([
        testCase(ATests.allTests),
        testCase(BTests.allTests),
        ])

#endif