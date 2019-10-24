// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit
import Heartable
@testable import HeartableGame
import XCTest

final class HRT2DProgressNodeTests: XCTestCase {

    // MARK: - Prep

    static let nodeSize = CGSize(width: 1000, height: 20)
    static let nodeOrigin: CGPoint = .zero
    static let fillNodeOrigin = CGPoint(x: -500, y: -10)
    static let nodeStartFrame = CGRect(origin: fillNodeOrigin, size: nodeSize)

    @HRTLate var progressRep: HRT2DProgressRepresentable
    var node: HRT2DProgressNode { progressRep as! HRT2DProgressNode }

    override func setUp() {
        #if !os(macOS)
        progressRep = HRT2DProgressNode(color: .red, size: Self.nodeSize)
        #else
        progressRep = HRT2DProgressNode(color: NSColor.red, size: Self.nodeSize)
        #endif
    }

    // MARK: - Tests

    func testSetup() {
        XCTAssertEqual(progressRep.frame, Self.nodeStartFrame)
        XCTAssertEqual(node.fillNode.frame, Self.nodeStartFrame)

        #if !os(macOS)
        XCTAssertEqual(node.color.cgColor.alpha, 0)
        #else
        XCTAssertEqual(node.color.alphaComponent, 0)
        #endif
        XCTAssertEqual(node.fillNode.alpha, 1)
    }

    func testUpdateProgress() {
        progressRep.updateProgress(0.5)
        XCTAssertEqual(
            node.fillNode.frame,
            CGRect(origin: Self.fillNodeOrigin, size: CGSize(width: 500, height: 20))
        )

        progressRep.updateProgress(1)
        XCTAssertEqual(node.fillNode.frame, Self.nodeStartFrame)

        progressRep.updateProgress(0)
        XCTAssertEqual(
            node.fillNode.frame,
            CGRect(origin: Self.fillNodeOrigin, size: CGSize(width: 0, height: 20))
        )
    }

}
