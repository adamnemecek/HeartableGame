// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class SKView_GeometryTests: XCTestCase {

    // MARK: - Prep

    let accuracy: CGFloat = 0.01
    @HRTLate var view: SKView
    @HRTLate var scene: SKScene

    override func setUp() {
        super.setUp()
        view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        scene = SKScene(size: CGSize(width: 1024, height: 1366))
    }

    // MARK: - Tests

    func testFillSceneScale() {
        scene.scaleMode = .fill

        let factors = view.scaleFactors(to: scene)
        XCTAssertEqual(factors.width, 1024 / 375)
        XCTAssertEqual(factors.height, 1366 / 667)

        let size = view.size(in: scene)
        XCTAssertEqual(size, scene.size)
    }

    func testAspectFillSceneScale() {
        scene.scaleMode = .aspectFill

        let factors = view.scaleFactors(to: scene)
        XCTAssertEqual(factors.width, 1366 / 667)
        XCTAssertEqual(factors.height, 1366 / 667)

        let size = view.size(in: scene)
        let scaledSize = scene.size.scaled(toAspectRatioOf: view.bounds.size, mode: .aspectFit)
        XCTAssertEqual(size.width, scaledSize.width, accuracy: accuracy)
        XCTAssertEqual(size.height, scaledSize.height, accuracy: accuracy)
    }

    func testAspectFitSceneScale() {
        scene.scaleMode = .aspectFit

        let factors = view.scaleFactors(to: scene)
        XCTAssertEqual(factors.width, 1024 / 375)
        XCTAssertEqual(factors.height, 1024 / 375)

        let size = view.size(in: scene)
        let scaledSize = scene.size.scaled(toAspectRatioOf: view.bounds.size, mode: .aspectFill)
        XCTAssertEqual(size.width, scaledSize.width, accuracy: accuracy)
        XCTAssertEqual(size.height, scaledSize.height, accuracy: accuracy)
    }

    func testResizeSceneScale() {
        scene.scaleMode = .resizeFill

        let factors = view.scaleFactors(to: scene)
        XCTAssertEqual(factors.width, 1)
        XCTAssertEqual(factors.height, 1)

        let scaledSize = view.size(in: scene)
        XCTAssertEqual(scaledSize, view.bounds.size)
    }

}
