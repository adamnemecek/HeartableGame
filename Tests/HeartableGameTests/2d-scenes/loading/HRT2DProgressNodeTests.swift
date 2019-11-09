// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit
import Heartable
@testable import HeartableGame
import XCTest

final class HRT2DProgressNodeTests: XCTestCase {

    // MARK: - Prep

    class Node: HRT2DProgressNode {}

    static let nodeSize = CGSize(width: 1000, height: 20)
    static let nodeOrigin: CGPoint = .zero
    static let fillNodeOrigin = CGPoint(x: -500, y: -10)
    static let nodeStartFrame = CGRect(origin: fillNodeOrigin, size: nodeSize)

    @HRTLate var progressRep: SKNode & HRT2DProgressRepresentable
    var node: HRT2DProgressNode { progressRep as! HRT2DProgressNode }

    override func setUp() {
        #if !os(macOS)
        progressRep = Node(
            texture: nil,
            color: .red,
            startSize: CGSize(width: 0, height: 20),
            fullWidth: 1000
        )
        #else
        progressRep = Node(
            texture: nil,
            color: NSColor.red,
            startSize: CGSize(width: 0, height: 20),
            fullWidth: 1000
        )
        #endif
    }

    // MARK: - Tests

    func testSetup() {
        XCTAssertEqual(progressRep.frame, Self.nodeStartFrame)
        XCTAssertEqual(
            node.fillNode.frame,
            CGRect(origin: Self.fillNodeOrigin, size: CGSize(width: 0, height: 20))
        )

        #if !os(macOS)
        XCTAssertEqual(node.color.cgColor.alpha, 0)
        #else
        XCTAssertEqual(node.color.alphaComponent, 0)
        #endif
        XCTAssertEqual(node.fillNode.alpha, 1)
    }

    func testUpdateProgress() {
        let exp1 = expectation(description: "updated progress to 50%")
        let exp2 = expectation(description: "updated progress to 100%")
        let exp3 = expectation(description: "updated progress to 0%")

        progressRep.updateProgress(0.5, animated: false) {
            XCTAssertEqual(
                self.node.fillNode.frame,
                CGRect(origin: Self.fillNodeOrigin, size: CGSize(width: 500, height: 20))
            )
            exp1.fulfill()

            self.progressRep.updateProgress(1, animated: false) {
                XCTAssertEqual(self.node.fillNode.frame, Self.nodeStartFrame)
                exp2.fulfill()

                self.progressRep.updateProgress(0, animated: false) {
                    XCTAssertEqual(
                        self.node.fillNode.frame,
                        CGRect(origin: Self.fillNodeOrigin, size: CGSize(width: 0, height: 20))
                    )
                    exp3.fulfill()
                }
            }
        }

        XCTWaiter.wait(for: [exp1, exp2, exp3], timeout: 3).process()
    }

}
