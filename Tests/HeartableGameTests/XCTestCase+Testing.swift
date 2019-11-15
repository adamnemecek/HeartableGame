// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import XCTest

public extension XCTestCase {

    class func dsleep(_ seconds: Double) {
        usleep(useconds_t(seconds * 1000000))
    }

    func dsleep(_ seconds: Double) {
        usleep(useconds_t(seconds * 1000000))
    }

}

// MARK: - Assertions

public extension XCTestCase {

    // MARK: Fatal error

    func HRTAssertFatalError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let fatalErrorExpectation = expectation(description: "Assert that fatal error did occur.")

        HRTFatalErrorBehavior.set { _, _, _ in
            fatalErrorExpectation.fulfill()
            never()
        }
        defer { HRTFatalErrorBehavior.reset() }

        DispatchQueue.global(qos: .userInitiated).async { _ = try! expression() }

        if XCTWaiter.wait(for: [fatalErrorExpectation], timeout: 1) != .completed {
            XCTFail(failureMessage(message(), for: "HRTAssertFatalError"), file: file, line: line)
        }
    }

    func HRTAssertNoFatalError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let noFatalErrorExpectation = expectation(
            description: "Assert that fatal error did not occur."
        )
        noFatalErrorExpectation.isInverted = true

        HRTFatalErrorBehavior.set { _, _, _ in
            noFatalErrorExpectation.fulfill()
            never()
        }
        defer { HRTFatalErrorBehavior.reset() }

        DispatchQueue.global(qos: .userInitiated).async { _ = try! expression() }

        if XCTWaiter.wait(for: [noFatalErrorExpectation], timeout: 1) != .completed {
            XCTFail(failureMessage(message(), for: "HRTAssertNoFatalError"), file: file, line: line)
        }
    }

    // MARK: - Precondition

    func HRTAssertPreconditionError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let message = message()
        HRTPreconditionBehavior.set { condition, _, _, _ in
            if condition {
                XCTFail(
                    self.failureMessage(message, for: "HRTAssertPreconditionError"),
                    file: file,
                    line: line
                )
            }
        }
        defer { HRTPreconditionBehavior.reset() }

        _ = try! expression()
    }

    func HRTAssertNoPreconditionError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let message = message()
        HRTPreconditionBehavior.set { condition, _, _, _ in
            if !condition {
                XCTFail(
                    self.failureMessage(message, for: "HRTAssertNoPreconditionError"),
                    file: file,
                    line: line
                )
            }
        }
        defer { HRTPreconditionBehavior.reset() }

        _ = try! expression()
    }

    // MARK: - Assertion

    func HRTAssertAssertionError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let message = message()
        HRTAssertBehavior.set { condition, _, _, _ in
            if condition {
                XCTFail(
                    self.failureMessage(message, for: "HRTAssertAssertionError"),
                    file: file,
                    line: line
                )
            }
        }
        defer { HRTAssertBehavior.reset() }

        _ = try! expression()
    }

    func HRTAssertNoAssertionError(
        _ expression: @escaping @autoclosure () throws -> Any,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let message = message()
        HRTAssertBehavior.set { condition, _, _, _ in
            if !condition {
                XCTFail(
                    self.failureMessage(message, for: "HRTAssertNoAssertionError"),
                    file: file,
                    line: line
                )
            }
        }
        defer { HRTAssertBehavior.reset() }

        _ = try! expression()
    }

    // MARK: Utils

    private func failureMessage(_ message: String, for assertionName: String) -> String {
        let errorMessage = "\(assertionName) failed"
        return message.isEmpty ? errorMessage : errorMessage + " - \(message)"
    }

}
