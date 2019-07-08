#if os(Linux)

import XCTest
@testable import MyFrameworkTests

    extension ATests {
        static let allTests = [
                ("test001",test001),
                ("test002",test002),
            ]
    }

    extension CTests {
        static let allTests = [
                ("test001",test001),
                ("test002",test002),
                ("test003",test003),
            ]
    }

    XCTMain([
        testCase(ATests.allTests),
        testCase(CTests.allTests),
        ])

#endif