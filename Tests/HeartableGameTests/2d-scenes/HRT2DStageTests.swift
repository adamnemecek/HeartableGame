// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class HRT2DStageTests: XCTestCase {

    // MARK: - Prep

    // Scenes

    class BaseScene: HRT2DScene, HRTSelfMaking, HRTTypeSized {
        static var typeSize: CGSize = .zero

        override func didMove(to view: SKView) {
            super.didMove(to: view)
            HRT2DStageTests.moved1?()
        }
    }

    class SceneA: BaseScene {}
    class SceneB: BaseScene {}
    class SceneC: BaseScene {}
    class SceneD: BaseScene {
        override static func loadAssets(completion: @escaping HRTBlock) {
            dsleep(wait1)
            load1?()
            completion()
        }
    }

    @HRTLate var sceneAInfo: HRT2DSceneInfo
    @HRTLate var sceneBInfo: HRT2DSceneInfo
    @HRTLate var sceneCInfo: HRT2DSceneInfo
    @HRTLate var sceneDInfo: HRT2DSceneInfo

    // Scripts

    lazy var sceneGraph1: [HRT2DSceneInfo: Set<HRT2DSceneInfo>] = {
        [
            sceneAInfo: Set([sceneBInfo, sceneCInfo]),
            sceneBInfo: Set([sceneDInfo]),
            sceneCInfo: Set([]),
            sceneDInfo: Set([])
        ]
    }()
    lazy var script1 = HRT2DScript(sceneGraph1, openingScene: sceneAInfo)

    // Loading

    static var wait1 = 1.0
    static var load1: HRTBlock?

    class ProgressSceneA: HRT2DProgressScene {
        override class func make() -> Self { return ProgressSceneA() as! Self }

        var moveCallback: HRTBlock?
        var reportCallback: HRTBlock?
        var failureCallback: HRTBlock?

        override func didMove(to view: SKView) {
            super.didMove(to: view)
            moveCallback?()
        }

        override func reportProgress(_ progress: Progress) {
            super.reportProgress(progress)
            reportCallback?()
        }

        override func reportFailure() {
            super.reportFailure()
            failureCallback?()
        }
    }

    // Inputs

    class InputSourceA: HRT2DGameInputSource {
        weak var gameDelegate: HRT2DGameInputSourceGameDelegate?
        weak var unitDelegate: HRT2DGameInputSourceUnitDelegate?
        func reset() {}
    }

    let inputSource1 = InputSourceA()

    lazy var input1 = HRT2DGameInput(inputSource1)

    // Views

    static var moved1: HRTBlock?

    var view1 = SKView()

    // MARK: Lifecycle

    override func setUp() {
        sceneAInfo = makeSceneInfo("a", sceneType: SceneA.self)
        sceneBInfo = makeSceneInfo("b", sceneType: SceneB.self)
        sceneCInfo = makeSceneInfo("c", sceneType: SceneC.self)
        sceneDInfo = makeSceneInfo("d", sceneType: SceneD.self)

        view1 = SKView()
        Self.wait1 = 1.0
        Self.load1 = nil
    }

    // MARK: - Utils

    func makeSceneInfo(_ sceneKey: String, sceneType: HRT2DScene.Type) -> HRT2DSceneInfo {
        HRT2DSceneInfo(
            sceneKey: sceneKey,
            fileName: "",
            sceneType: sceneType,
            sceneChange: true,
            longLived: false
        )
    }

    // MARK: - Tests

    func testInit() {
        let stage = HRT2DStage(view1, input: input1, script: script1)

        let sceneALoader = stage.sceneLoaders[sceneAInfo]
        XCTAssertNil(sceneALoader?.progress)
        XCTAssert(sceneALoader?.stateMachine.currentState is HRTLoad2DSceneReady)

        let sceneBLoader = stage.sceneLoaders[sceneBInfo]
        XCTAssertNil(sceneBLoader?.progress)
        XCTAssert(sceneBLoader?.stateMachine.currentState is HRTLoad2DSceneReady)

        let sceneCLoader = stage.sceneLoaders[sceneCInfo]
        XCTAssertNil(sceneCLoader?.progress)
        XCTAssert(sceneCLoader?.stateMachine.currentState is HRTLoad2DSceneReady)

        let sceneDLoader = stage.sceneLoaders[sceneDInfo]
        XCTAssertNil(sceneDLoader?.progress)
        XCTAssert(sceneDLoader?.stateMachine.currentState is HRTLoad2DSceneReady)
    }

    func testProgressScene_loadSuccess() {
        let stage = HRT2DStage(view1, input: input1, script: script1)
        stage.progressSceneType = ProgressSceneA.self
        let progressScene = stage.progressScene as! ProgressSceneA

        let exp1 = expectation(description: "progress scene is presented")
        progressScene.moveCallback = {
            XCTAssert(stage.sceneLoaders[self.sceneDInfo]?.isRequested == true)
            XCTAssertEqual(progressScene.view, self.view1)
            exp1.fulfill()
        }

        let exp2 = expectation(description: "progress scene is reported to")
        progressScene.reportCallback = {
            exp2.fulfill()
            progressScene.reportCallback = nil
        }

        let exp3 = expectation(description: "sceneD is loading")
        Self.load1 = {
            XCTAssert(self.view1.scene === progressScene)
            exp3.fulfill()
        }

        let exp4 = expectation(description: "sceneD is presented")
        Self.moved1 = {
            XCTAssert(self.view1.scene is SceneD)
            exp4.fulfill()
        }

        stage.transition(to: sceneDInfo)

        XCTWaiter.wait(for: [exp1, exp2, exp3, exp4], timeout: 1.5).process()
    }

    func testProgressScene_loadFailure() {
        let stage = HRT2DStage(view1, input: input1, script: script1)
        stage.progressSceneType = ProgressSceneA.self
        let progressScene = stage.progressScene as! ProgressSceneA

        let exp1 = expectation(description: "progress scene is presented")
        progressScene.moveCallback = {
            let dLoader = stage.sceneLoaders[self.sceneDInfo]
            XCTAssertNotNil(dLoader)
            dLoader?.cancel()
            exp1.fulfill()
        }

        let exp2 = expectation(description: "progress scene reports failure")
        progressScene.failureCallback = { exp2.fulfill() }

        let exp3 = expectation(description: "sceneD is presented")
        exp3.isInverted = true
        Self.moved1 = { exp3.fulfill() }

        stage.transition(to: sceneDInfo)

        XCTWaiter.wait(for: [exp1, exp2, exp3], timeout: 1.5).process {
            XCTAssert(self.view1.scene is ProgressSceneA)
        }
    }

}
