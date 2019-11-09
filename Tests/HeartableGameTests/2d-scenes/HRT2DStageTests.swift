// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class HRT2DStageTests: XCTestCase {

    // MARK: - Prep

    // Stage

    @HRTLate var stage: HRT2DStage

    // Scenes

    class BaseScene: HRT2DScene, HRTSelfMaking, HRTTypeSized {
        static var typeSize: CGSize = .zero
        override func didMove(to view: SKView) {
            super.didMove(to: view)
            moved1?()
        }
        override class func unloadAssets() {}
    }

    class SceneA: BaseScene {
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] {
            [DepA.self, DepB.self]
        }
        static var unload: HRTBlock?
        override static func unloadAssets() { unload?() }
    }

    class SceneB: BaseScene {
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [DepC.self] }
        static var unload: HRTBlock?
        override static func unloadAssets() { unload?() }
    }

    class SceneC: BaseScene {
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [DepD.self] }
        static var unload: HRTBlock?
        override static func unloadAssets() { unload?() }
    }

    class SceneD: BaseScene {
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [DepA.self] }
        override static func loadAssets(completion: @escaping HRTBlock) {
            dsleep(wait1)
            load1?()
            completion()
        }
        static var unload: HRTBlock?
        override static func unloadAssets() { unload?() }
    }

    class DepA: HRTAssetsLoading {
        static var shouldLoadAssets: Bool { true }
        static var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        static func loadAssets(completion: @escaping HRTBlock) { completion() }
        static var unload: HRTBlock?
        static func unloadAssets() { unload?() }
    }

    class DepB: HRTAssetsLoading {
        static var shouldLoadAssets: Bool { true }
        static var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        static func loadAssets(completion: @escaping HRTBlock) { completion() }
        static var unload: HRTBlock?
        static func unloadAssets() { unload?() }
    }

    class DepC: HRTAssetsLoading {
        static var shouldLoadAssets: Bool { true }
        static var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        static func loadAssets(completion: @escaping HRTBlock) { completion() }
        static var unload: HRTBlock?
        static func unloadAssets() { unload?() }
    }

    class DepD: HRTAssetsLoading {
        static var shouldLoadAssets: Bool { true }
        static var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        static func loadAssets(completion: @escaping HRTBlock) { completion() }
        static var unload: HRTBlock?
        static func unloadAssets() { unload?() }
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

        override func wrapUp(_ completion: @escaping HRTBlock) {
            reportCallback?()
            super.wrapUp(completion)
        }

        override func reportFailure() {
            super.reportFailure()
            failureCallback?()
        }
    }

    // Inputs

    class InputSourceA: HRT2DGameInputSource {
        weak var gameDelegate: HRT2DGameInputSourceGameDelegate?
        var unitDelegates = [String: HRT2DGameInputSourceUnitDelegate]()
        func reset() {}
    }

    let inputSource1 = InputSourceA()

    lazy var input1 = HRT2DGameInput(inputSource1)

    // Views

    static var moved1: HRTBlock?

    var view1 = SKView()

    // MARK: Lifecycle

    override func setUp() {
        SceneA.unload = nil
        SceneB.unload = nil
        SceneC.unload = nil
        SceneD.unload = nil

        DepA.unload = nil
        DepB.unload = nil

        sceneAInfo = makeSceneInfo("a", sceneType: SceneA.self)
        sceneBInfo = makeSceneInfo("b", sceneType: SceneB.self)
        sceneCInfo = makeSceneInfo("c", sceneType: SceneC.self)
        sceneDInfo = makeSceneInfo("d", sceneType: SceneD.self)

        Self.wait1 = 1.0
        Self.load1 = nil
        Self.moved1 = nil
        view1 = SKView()

        stage = HRT2DStage(
            script1,
            view: view1,
            input: input1,
            progressScene: ProgressSceneA.make()
        )
    }

    // MARK: - Utils

    func makeSceneInfo(_ sceneKey: String, sceneType: HRT2DScene.Type) -> HRT2DSceneInfo {
        HRT2DSceneInfo(
            sceneKey: sceneKey,
            fileName: "",
            sceneType: sceneType,
            preloads: true,
            showsLoading: true,
            isLongLived: false,
            isHaptic: false
        )
    }

    // MARK: - Tests

    func testInit() {
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
        stage.progressScene = ProgressSceneA.make()
        let progressScene = stage.progressScene as! ProgressSceneA

        let exp1 = expectation(description: "progress scene is presented")
        progressScene.moveCallback = {
            XCTAssert(self.stage.sceneLoaders[self.sceneDInfo]?.isRequested == true)
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

        stage.loadAndPresentScene(sceneDInfo)

        let exps = [exp1, exp2, exp3, exp4]
        XCTWaiter.wait(for: exps, timeout: 1.5).process()
    }

    func testProgressScene_loadFailure() {
        stage.progressScene = ProgressSceneA.make()
        let progressScene = stage.progressScene as! ProgressSceneA

        let exp1 = expectation(description: "progress scene is presented")
        progressScene.moveCallback = {
            let dLoader = self.stage.sceneLoaders[self.sceneDInfo]
            XCTAssertNotNil(dLoader)
            dLoader?.cancel()
            exp1.fulfill()
        }

        let exp2 = expectation(description: "progress scene reports failure")
        progressScene.failureCallback = { exp2.fulfill() }

        let exp3 = expectation(description: "sceneD is presented")
        exp3.isInverted = true
        Self.moved1 = { exp3.fulfill() }

        stage.loadAndPresentScene(sceneDInfo)

        XCTWaiter.wait(for: [exp1, exp2, exp3], timeout: 1.5).process {
            XCTAssert(self.view1.scene is ProgressSceneA)
        }
    }

    func testUnload() {
        stage.currSceneInfo = sceneBInfo

        let exp1 = expectation(description: "SceneA is unloaded.")
        SceneA.unload = { exp1.fulfill() }

        let exp2 = expectation(description: "SceneB is not unloaded.")
        exp2.isInverted = true
        SceneB.unload = { exp2.fulfill() }

        let exp3 = expectation(description: "SceneC is unloaded.")
        SceneC.unload = { exp3.fulfill() }

        let exp4 = expectation(description: "SceneD is not unloaded.")
        exp4.isInverted = true
        SceneD.unload = { exp4.fulfill() }

        let exp5 = expectation(description: "DepA is not unloaded.")
        exp5.isInverted = true
        DepA.unload = { exp5.fulfill() }

        let exp6 = expectation(description: "DepB is unloaded.")
        DepB.unload = { exp6.fulfill() }

        let exp7 = expectation(description: "DepC is not unloaded.")
        exp7.isInverted = true
        DepC.unload = { exp7.fulfill() }

        let exp8 = expectation(description: "DepD is unloaded.")
        DepD.unload = { exp8.fulfill() }

        stage.releaseUnneededAssets(for: sceneBInfo)

        let exps = [exp1, exp2, exp3, exp4, exp5, exp6, exp7, exp8]
        XCTWaiter.wait(for: exps, timeout: 1).process()
    }

}
