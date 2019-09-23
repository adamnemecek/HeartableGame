import XCTest
@testable import HeartableGame

final class HeartableGameTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HeartableGame().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
