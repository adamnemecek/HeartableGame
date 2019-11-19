// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class SKNode_ViewTests: XCTestCase {

    // MARK: - Constants

    static let viewSizeAspectFittingScene = CGSize(width: 768, height: 1366)

    // MARK: - Prep

    @HRTLate var view1: SKView
    @HRTLate var scene1: HRT2DScene
    @HRTLate var node1: SKNode

    override func setUp() {
        view1 = SKView(frame: CGRect(origin: .zero, size: CGSize(width: 375, height: 667)))
        scene1 = HRT2DScene(size: CGSize(width: 1024, height: 1366))
        node1 = SKNode()

        scene1.addChild(node1)
        view1.presentScene(scene1)
    }

    // MARK: - Tests

    func testViewGuide_full_noMargins() {
        let viewGuide1 = node1.viewGuide(.full)
        XCTAssertNotNil(viewGuide1)
        XCTAssertEqual(viewGuide1!.origin.x, 128, accuracy: 0.1)
        XCTAssertEqual(viewGuide1!.origin.y, 0, accuracy: 0.1)
        XCTAssertEqual(viewGuide1!.size.width, 768, accuracy: 1)
        XCTAssertEqual(viewGuide1!.size.height, 1366, accuracy: 1)
    }

    func testViewGuide_full_withMargins() {
        let margins1 = HRTInsets(top: 10, left: 20, bottom: 30, right: 40)
        let viewGuide1 = node1.viewGuide(.full, margins: margins1)
        XCTAssertNotNil(viewGuide1)
        XCTAssertEqual(viewGuide1!.origin.x, 148, accuracy: 0.1)
        XCTAssertEqual(viewGuide1!.origin.y, 30, accuracy: 0.1)
        XCTAssertEqual(viewGuide1!.size.width, 708, accuracy: 1)
        XCTAssertEqual(viewGuide1!.size.height, 1326, accuracy: 1)
    }

}
