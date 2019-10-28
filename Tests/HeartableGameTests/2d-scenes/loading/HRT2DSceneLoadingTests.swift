// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit
import Heartable
@testable import HeartableGame
import XCTest

final class HRT2DSceneLoadingTests: XCTestCase {

    // MARK: - Prep

    class LoaderDelegate: HRT2DSceneLoaderDelegate {
        var success: ((HRT2DSceneLoader, HRT2DScene) -> Void)?
        var failure: ((HRT2DSceneLoader) -> Void)?

        func sceneLoaderDidLoad(_ sceneLoader: HRT2DSceneLoader, scene: HRT2DScene) {
            success?(sceneLoader, scene)
        }

        func sceneLoaderDidFail(_ sceneLoader: HRT2DSceneLoader) {
            failure?(sceneLoader)
        }
    }

    static let allSceneTypes: [BaseScene.Type] = [
        SceneA.self, SceneB.self, SceneC.self
    ]

    class BaseScene: HRT2DScene, HRTTypeSized, HRTSelfMaking {
        static let typeSize = CGSize(square: 100)
        override class var shouldLoadAssets: Bool { true }
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        class var testLoad: HRTBlock? { nil }
        override class func loadAssets(completion: @escaping HRTBlock) {
            testLoad?()
            completion()
        }
        class func reset() {}
    }

    class SceneA: BaseScene {
        static var block: HRTBlock?
        override class var testLoad: HRTBlock? { block }
        override class func reset() { super.reset(); block = nil }
    }

    class SceneB: BaseScene {
        static var block: HRTBlock?
        override class var testLoad: HRTBlock? { block }
        override class func reset() { super.reset(); block = nil }
    }

    class SceneC: BaseScene {
        static var block: HRTBlock?
        override class var testLoad: HRTBlock? { block }
        override class func reset() { super.reset(); block = nil }

        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] {
            [SceneA.self, SceneB.self]
        }
    }

    static let sceneAInfo = makeSceneInfo("A", sceneType: SceneA.self)
    static let sceneBInfo = makeSceneInfo("B", sceneType: SceneB.self)
    static let sceneCInfo = makeSceneInfo("C", sceneType: SceneC.self)

    // MARK: - Lifecycle

    override func setUp() {
        Self.allSceneTypes.forEach { $0.reset() }
    }

    // MARK: - Utils

    static func makeSceneInfo(_ sceneKey: String, sceneType: HRT2DScene.Type) -> HRT2DSceneInfo {
        HRT2DSceneInfo(
            sceneKey: sceneKey,
            fileName: "",
            sceneType: sceneType,
            longLived: false
        )
    }

    // MARK: - Tests

    func testSceneLoader_singleAssetType() {
        let expA = expectation(description: "A is loading")
        SceneA.block = { expA.fulfill() }

        let expSuccess = expectation(description: "loading success")
        let expNoFailure = expectation(description: "no loading failure")
        expNoFailure.isInverted = true

        let sceneLoader = HRT2DSceneLoader(Self.sceneAInfo)
        let delegate = LoaderDelegate()
        delegate.success = {
            XCTAssert(sceneLoader === $0)
            XCTAssert(sceneLoader.scene is SceneA)
            XCTAssert($1 is SceneA)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneFinished)
            XCTAssert(sceneLoader.progress?.fractionCompleted == 1)
            expSuccess.fulfill()
        }
        delegate.failure = { _ in expNoFailure.fulfill() }
        sceneLoader.delegate = delegate

        XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
        sceneLoader.load()

        let exps = [expA, expSuccess, expNoFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testSceneLoader_multipleAssetTypes() {
        let sceneLoader = HRT2DSceneLoader(Self.sceneCInfo)

        let expSuccess = expectation(description: "loading success")
        let expNoFailure = expectation(description: "no loading failure")
        expNoFailure.isInverted = true

        let delegate = LoaderDelegate()
        delegate.success = {
            XCTAssert(sceneLoader === $0)
            XCTAssert(sceneLoader.scene is SceneC)
            XCTAssert($1 is SceneC)
            XCTAssert(sceneLoader.progress!.fractionCompleted == 1)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneFinished)
            expSuccess.fulfill()
        }
        delegate.failure = { _ in expNoFailure.fulfill() }
        sceneLoader.delegate = delegate

        let expA = expectation(description: "A is loading")
        SceneA.block = {
            XCTAssert(sceneLoader.progress!.fractionCompleted < 1)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneLoading)
            expA.fulfill()
        }
        let expB = expectation(description: "B is loading")
        SceneB.block = {
            XCTAssert(sceneLoader.progress!.fractionCompleted < 1)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneLoading)
            expB.fulfill()
        }
        let expC = expectation(description: "C is loading")
        SceneC.block = {
            XCTAssert(sceneLoader.progress!.fractionCompleted < 1)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneLoading)
            expC.fulfill()
        }

        XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
        sceneLoader.load()

        let exps = [expA, expB, expC, expSuccess, expNoFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testSceneLoader_cancelLoader() {
        let sceneLoader = HRT2DSceneLoader(Self.sceneCInfo)
        XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
        sceneLoader.cancel()
        XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)

        let expNoSuccess = expectation(description: "no loading success")
        expNoSuccess.isInverted = true
        let expFailure = expectation(description: "loading failed")

        let delegate = LoaderDelegate()
        delegate.success = { _, _ in expNoSuccess.fulfill() }
        delegate.failure = {
            XCTAssert(sceneLoader === $0)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
            sceneLoader.cancel()
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
            expFailure.fulfill()
        }
        sceneLoader.delegate = delegate

        SceneA.block = { sceneLoader.cancel() }
        sceneLoader.load()

        let exps = [expNoSuccess, expFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process {

        }
    }

    func testSceneLoader_cancelProgress() {
        let sceneLoader = HRT2DSceneLoader(Self.sceneCInfo)

        let expNoSuccess = expectation(description: "no loading success")
        expNoSuccess.isInverted = true
        let expFailure = expectation(description: "loading failed")

        let delegate = LoaderDelegate()
        delegate.success = { _, _ in expNoSuccess.fulfill() }
        delegate.failure = {
            XCTAssert(sceneLoader === $0)
            XCTAssert(sceneLoader.stateMachine.currentState is HRTLoad2DSceneReady)
            expFailure.fulfill()
        }
        sceneLoader.delegate = delegate

        SceneA.block = { sceneLoader.progress?.cancel() }
        sceneLoader.load()

        let exps = [expNoSuccess, expFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

}
