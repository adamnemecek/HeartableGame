// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class SKNode_ScaleTests: XCTestCase {

    // MARK: - Prep

    @HRTLate var scene1: HRT2DScene

    @HRTLate var node1: SKNode
    @HRTLate var node2: SKNode
    @HRTLate var node3: SKNode
    @HRTLate var node4: SKNode
    @HRTLate var node5: SKNode
    @HRTLate var node6: SKNode

    override func setUp() {
        scene1 = HRT2DScene(size: CGSize(width: 100, height: 200))
        node1 = SKNode()
        node2 = SKNode()
        node3 = SKNode()
        node4 = SKNode()
        node5 = SKNode()
        node6 = SKNode()

        scene1.addChild(node1)
        node1.addChild(node2)
        node2.addChild(node3)
        node1.addChild(node4)
        scene1.addChild(node5)
    }

    // MARK: - Tests

    func testNoScaleChanges() {
        XCTAssert(scene1.accumulatedXScale() == 1)
        XCTAssert(node1.accumulatedXScale() == 1)
        XCTAssert(node2.accumulatedXScale() == 1)
        XCTAssert(node3.accumulatedXScale() == 1)
        XCTAssert(node4.accumulatedXScale() == 1)
        XCTAssert(node5.accumulatedXScale() == 1)
    }

    func testNilScale() {
        XCTAssertNil(node6.accumulatedXScale(through: node1))
    }

    func testScaleThroughNode_noChange() {
        XCTAssert(scene1.accumulatedXScale(through: scene1) == 1)
        XCTAssert(node1.accumulatedXScale(through: scene1) == 1)
        XCTAssert(node2.accumulatedXScale(through: scene1) == 1)
        XCTAssert(node3.accumulatedXScale(through: scene1) == 1)
        XCTAssert(node4.accumulatedXScale(through: scene1) == 1)
        XCTAssert(node5.accumulatedXScale(through: scene1) == 1)
    }

    func testScaleChanges() {
        node2.xScale = 2
        XCTAssertEqual(node3.accumulatedXScale(), 2)
        XCTAssertEqual(node3.accumulatedYScale(), 1)

        node3.yScale = 3
        XCTAssertEqual(node3.accumulatedXScale(), 2)
        XCTAssertEqual(node3.accumulatedYScale(), 3)

        node3.xScale = 5
        XCTAssertEqual(node3.accumulatedXScale(), 10)
        XCTAssertEqual(node3.accumulatedYScale(), 3)

        node1.xScale = 2
        XCTAssertEqual(node3.accumulatedXScale(), 20)
        XCTAssertEqual(node3.accumulatedYScale(), 3)

        XCTAssertEqual(node3.accumulatedXScale(through: node2), 10)
        XCTAssertEqual(node3.accumulatedYScale(through: node2), 3)

        XCTAssertEqual(node2.accumulatedXScale(through: node2), 2)
        XCTAssertEqual(node2.accumulatedYScale(through: node2), 1)

        XCTAssertEqual(node1.accumulatedXScale(through: scene1), 2)
        XCTAssertEqual(node1.accumulatedYScale(through: scene1), 1)
    }

}
