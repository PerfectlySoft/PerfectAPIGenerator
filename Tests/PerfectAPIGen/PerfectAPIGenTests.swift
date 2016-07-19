import XCTest
@testable import PerfectAPIGen

class PerfectAPIGenTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(PerfectAPIGen().text, "Hello, World!")
    }


    static var allTests : [(String, (PerfectAPIGenTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
