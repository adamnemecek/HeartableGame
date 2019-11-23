// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class HRT2DCurtainTests: XCTestCase {

    // MARK: - Prep

    @HRTLate var scene1: HRT2DScene
    @HRTLate var curtain1: HRT2DCurtain

    override func setUp() {
        scene1 = HRT2DScene()

        #if !os(macOS)
        curtain1 = HRT2DCurtain(.clear)
        #else
        curtain1 = HRT2DCurtain(.clear)
        #endif
    }

    // MARK: - Tests

    func testCurtainInit() {
        scene1.curtain = curtain1
        XCTAssertNotNil(curtain1.rootNode.parent)
        XCTAssertEqual(curtain1.rootNode.parent, scene1.camera)
        XCTAssertEqual(curtain1.rootNode.zPosition, 999999)
        XCTAssert(curtain1.rootNode.inParentHierarchy(scene1))
    }

}
