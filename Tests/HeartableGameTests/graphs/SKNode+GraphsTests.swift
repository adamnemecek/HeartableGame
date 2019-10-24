// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class SKNode_GraphsTests: XCTestCase {

    // MARK: - Prep

    let accuracy: CGFloat = 0.01

    @HRTLate var scene1: SKScene
    @HRTLate var scene2: SKScene

    @HRTLate var node1: SKNode
    @HRTLate var node2: SKNode
    @HRTLate var node3: SKNode
    @HRTLate var node4: SKNode
    @HRTLate var node5: SKNode

    override func setUp() {
        super.setUp()

        scene1 = SKScene(size: .zero)
        scene2 = SKScene(size: .zero)

        node1 = SKNode()
        node2 = SKNode()
        node3 = SKNode()
        node4 = SKNode()
        node5 = SKNode()
    }

    // MARK: - Tests

    func testPathToRoot() {
        XCTAssert(scene1.pathToRoot() == [scene1])

        scene1.addChild(node1)
        node1.addChild(node2)
        node2.addChild(node3)
        node3.addChild(node4)
        XCTAssert(node4.pathToRoot() == [node4, node3, node2, node1, scene1])

        node1.removeAllChildren()
        XCTAssert(node4.pathToRoot() == [node4, node3, node2])
    }

    func testLowestCommonAncester_baseCases() {
        XCTAssertNil(SKNode.lowestCommonAncestor(lhs: scene1, rhs: node1))
        XCTAssertNotNil(SKNode.lowestCommonAncestor(lhs: scene1, rhs: scene1))
    }

    func testLowestCommonAncestor() {
        scene1.addChild(node1)
        node1.addChild(node2)
        node2.addChild(node3)
        XCTAssert(SKNode.lowestCommonAncestor(lhs: scene1, rhs: node3) === scene1)
        XCTAssert(SKNode.lowestCommonAncestor(lhs: node1, rhs: node3) === node1)

        scene1.addChild(node4)
        node1.addChild(node5)
        XCTAssert(SKNode.lowestCommonAncestor(lhs: node3, rhs: node4) === scene1)
        XCTAssert(SKNode.lowestCommonAncestor(lhs: node3, rhs: node5) === node1)
    }

}
