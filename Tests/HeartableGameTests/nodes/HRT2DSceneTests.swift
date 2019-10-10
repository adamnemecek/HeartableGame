// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

@available(macOS 10.12, iOS 10.0, *)
final class HRT2DSceneTests: XCTestCase {

    // MARK: - Prep

    static let sceneSize = CGSize(width: 1024, height: 1366)

    class A: HRT2DScene, HRTTypeSized, HRTSelfMaking {
        static let typeSize = sceneSize
    }

    // MARK: - Tests

    func testInit() {
        let scene1 = A(size: Self.sceneSize)
        let scene2 = A.make()
        XCTAssertEqual(scene1.size, scene2.size)
    }

}
