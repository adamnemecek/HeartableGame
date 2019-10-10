// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class SKNode_GeometryTests: XCTestCase {

    // MARK: - Prep

    let sceneSize = CGSize(width: 1000, height: 1500)
    let nodeSize = CGSize(width: 100, height: 100)

    @HRTLate var scene: SKScene
    @HRTLate var node0: SKSpriteNode
    @HRTLate var node1: SKSpriteNode
    @HRTLate var node2: SKSpriteNode
    @HRTLate var node3: SKSpriteNode

    override func setUp() {
        scene = SKScene(size: sceneSize)
        node0 = SKSpriteNode(color: .red, size: nodeSize)
        node0.anchorPoint = HRT2DPositionAnchor.center.unitPoint
        node0.position = CGPoint(x: 25, y: 175)
        scene.addChild(node0)

        node1 = SKSpriteNode(color: .cyan, size: nodeSize)
        node1.anchorPoint = HRT2DPositionAnchor.center.unitPoint
        node2 = SKSpriteNode(color: .blue, size: nodeSize)
        node2.anchorPoint = HRT2DPositionAnchor.center.unitPoint
        node3 = SKSpriteNode(color: .purple, size: nodeSize)
        node3.anchorPoint = HRT2DPositionAnchor.center.unitPoint
    }

    // MARK: - Tests

    // MARK: Placement

    func testNoRepositioning() {
        XCTAssertEqual(node1.position, CGPoint.zero)

        node1.align(to: .top)
        XCTAssertEqual(node1.position, CGPoint.zero)

        node1.align(to: .top, of: node0)
        XCTAssertEqual(node1.position, CGPoint.zero)
    }

    func testCenterPosition() {
        let center = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        let centerOffset = CGPoint(x: 50, y: -25) // arbitrary offset

        scene.addChild(node1)

        // No local anchor
        node1.align(to: .center)
        XCTAssertEqual(node1.position, center)
        node1.align(to: .center, constants: centerOffset)
        XCTAssertEqual(node1.position, center + centerOffset)
        node1.align(to: .center, of: node0)
        XCTAssertEqual(node1.position, node0.position)
        node1.align(to: .center, of: node0, constants: centerOffset)
        XCTAssertEqual(node1.position, node0.position + centerOffset)

        // With center local anchor
        node1.align(.center, to: .center)
        XCTAssertEqual(node1.position, center)
        node1.align(.center, to: .center, constants: centerOffset)
        XCTAssertEqual(node1.position, center + centerOffset)
        node1.align(.center, to: .center, of: node0)
        XCTAssertEqual(node1.position, node0.position)
        node1.align(.center, to: .center, of: node0, constants: centerOffset)
        XCTAssertEqual(node1.position, node0.position + centerOffset)

        // With different anchors
        node1.align(.bottom, to: .center)
        XCTAssertEqual(node1.position, center + CGPoint(x: 0, y: 50))
        node1.align(.topLeft, to: .center)
        XCTAssertEqual(node1.position, center + CGPoint(x: 50, y: -50))

        // With another anchor point
        node1.anchorPoint = CGPoint.zero
        node1.align(to: .center)
        XCTAssertEqual(node1.position, center)
        node1.align(.topRight, to: .center)
        XCTAssertEqual(node1.position, center + CGPoint(x: -100, y: -100))

        // With different parents
        node0.addChild(node2)
        node2.align(to: .center, of: node0)
        XCTAssertEqual(node2.position.x, 0, accuracy: 1)
        XCTAssertEqual(node2.position.y, 0, accuracy: 1)
        node2.align(to: .center, of: scene)
        XCTAssertEqual(node2.position, center + CGPoint(x: -25, y: -175))
        node1.align(to: .top, of: node2)
        XCTAssertEqual(node1.position, center + CGPoint(x: 0, y: 50))
    }

    func testCornerPosition() {
        let topRight = CGPoint(x: scene.frame.maxX, y: scene.frame.maxY)
        let cornerOffset = CGPoint(x: -50, y: -25) // arbitrary offset
        let anchorOffset = CGPoint(x: 50, y: 50) // positive offset from center
        let negAnchorOffset = CGPoint(x: -50, y: -50) // negative offset from center

        scene.addChild(node1)

        // No local anchor
        node1.align(to: .topRight)
        XCTAssertEqual(node1.position, topRight)
        node1.align(to: .topRight, constants: cornerOffset)
        XCTAssertEqual(node1.position, topRight + cornerOffset)
        node1.align(to: .topRight, of: node0)
        XCTAssertEqual(node1.position, node0.position + anchorOffset)
        node1.align(to: .topRight, of: node0, constants: cornerOffset)
        XCTAssertEqual(node1.position, node0.position + cornerOffset + anchorOffset)

        // With top right local anchor
        node1.align(.topRight, to: .topRight)
        XCTAssertEqual(node1.position, topRight + negAnchorOffset)
        node1.align(.topRight, to: .topRight, constants: cornerOffset)
        XCTAssertEqual(node1.position, topRight + cornerOffset + negAnchorOffset)
        node1.align(.topRight, to: .topRight, of: node0)
        XCTAssertEqual(node1.position, node0.position)
        node1.align(.topRight, to: .topRight, of: node0, constants: cornerOffset)
        XCTAssertEqual(node1.position, node0.position + cornerOffset)

        // With different anchors
        node1.align(.bottomLeft, to: .topRight)
        XCTAssertEqual(node1.position, topRight + anchorOffset)
        node1.align(.topLeft, to: .topRight)
        XCTAssertEqual(node1.position, topRight + CGPoint(x: 50, y: -50))

        // With another anchor point
        node1.anchorPoint = CGPoint.zero
        node1.align(to: .topRight)
        XCTAssertEqual(node1.position, topRight)
        node1.align(.topRight, to: .topRight)
        XCTAssertEqual(node1.position, topRight + CGPoint(x: -100, y: -100))

        // With different parents
        node0.addChild(node2)
        node2.align(to: .topRight, of: node0)
        XCTAssertEqual(node2.position.x, 50, accuracy: 1)
        XCTAssertEqual(node2.position.y, 50, accuracy: 1)
        node2.align(to: .topRight, of: scene)
        XCTAssertEqual(node2.position, topRight + CGPoint(x: -25, y: -175))
        node1.align(to: .topRight, of: node2)
        XCTAssertEqual(node1.position, topRight + anchorOffset)
    }

}
