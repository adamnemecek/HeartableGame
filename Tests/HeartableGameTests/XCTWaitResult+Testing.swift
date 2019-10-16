// Copyright © 2019 Heartable LLC. All rights reserved.

import XCTest

public extension XCTWaiter.Result {

    func process(_ completion: (() -> Void)? = nil) {
        switch self {
        case .completed:
            completion?()
        case .incorrectOrder:
            XCTAssert(false, "Expectations were fulfilled out of order.")
        case .interrupted:
            XCTAssert(false, "Wait for expectations was interrupted.")
        case .invertedFulfillment:
            XCTAssert(false, "Inverted expectations were fulfilled.")
        case .timedOut:
            XCTAssert(false, "Wait for expectations timed out.")
        @unknown default:
            XCTAssert(false, "Expectations fulfillment did not complete.")
        }
    }

}
