// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

#if !os(macOS)
import UIKit
#endif

/// Coordinator of scene loading and presentation.
final public class HRT2DStage {

    // MARK: - Props

    /// Content authority.
    public let script: HRT2DScript

    /// The presenting view.
    public let view: SKView

    /// Player control input.
    public let input: HRT2DGameInput

    #if DEBUG
    /// Debug UI.
    public var debugInputSource: HRT2DGameInputSource? {
        didSet {
            if let debugInputSource = debugInputSource {
                input.addSecondarySource(debugInputSource)
            }
            if let oldDebugInputSource = oldValue {
                input.removeSecondarySource(oldDebugInputSource)
            }
        }
    }
    #endif

    // MARK: Loading

    /// Loaders for all scenes.
    public let sceneLoaders: [HRT2DSceneInfo: HRT2DSceneLoader]

    /// Scene indicating loading progress.
    public var progressScene: HRT2DProgressRendering {
        didSet { progressScene.stage = self }
    }

    public var pretransitionScene: HRT2DScene? {
        didSet { pretransitionScene?.stage = self }
    }

    let loadQueue: HRTOperationQueue = {
        let queue = HRTOperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    // MARK: State

    /// Scenes that have been presented.
    var history = [HRT2DSceneInfo]()

    /// A scene's loading progress.
    var progress: Progress?

    /// Observation token for tracking loading progress.
    var progressObservation: NSKeyValueObservation?

    // MARK: Config

    public var presentTransition: SKTransition?

    public var nextPresentTransition: SKTransition?

    public var progressPresentTransition: SKTransition?

    // MARK: - Init

    public init(
        _ script: HRT2DScript,
        view: SKView,
        input: HRT2DGameInput = HRT2DGameInput(),
        progressScene: HRT2DProgressRendering
    ) {
        self.script = script
        self.view = view
        self.input = input
        self.progressScene = progressScene
        sceneLoaders = Dictionary(uniqueKeysWithValues: script.scenesGraph.keys.map {
            ($0, HRT2DSceneLoader($0))
        })

        sceneLoaders.values.forEach { $0.delegate = self }
        self.progressScene.stage = self
    }

    // MARK: - Functionality

    public var nextScenes: Set<HRT2DSceneInfo> {
        script.scenes(after: history.last)
    }

    // MARK: Preload scenes

    public func preloadNextScenes() {
        nextScenes.forEach { preloadScene($0) }
    }

    public func preloadScene(_ sceneInfo: HRT2DSceneInfo) {
        guard let loader = sceneLoaders[sceneInfo] else {
            assertionFailure("not a staged scene: \(sceneInfo)")
            return
        }

        guard sceneInfo.preloads else { return }
        enqueueLoadingTask(loader, qualityOfService: .utility)
    }

    // MARK: Load and visit scenes

    public func loadAndVisitNextScene(transition: SKTransition? = nil) {
        guard let next = nextScenes.first else { return }
        loadAndVisitScene(next, transition: transition)
    }

    public func loadAndVisitPrevScene(transition: SKTransition? = nil) {
        guard history.count >= 2 else { return }
        loadAndVisitScene(history[history.count - 2], revisiting: true, transition: transition)
    }

    public func loadAndVisitScene(
        _ sceneInfo: HRT2DSceneInfo,
        revisiting: Bool = false,
        transition: SKTransition? = nil
    ) {
        guard let loader = sceneLoaders[sceneInfo] else {
            assertionFailure("not a staged scene: \(sceneInfo)")
            return
        }

        if revisiting,
            // If revisiting a scene, get its most recent occurence.
            let index = history.lastIndex(of: sceneInfo)
        {
            // Clear out history from this scene onwards, including this scene itself (which will be
            // added to history again upon its presentation).
            history.removeLast(history.count - index)
        }

        if loader.isFinished {
            visitScene(loader, transition: transition)
        } else {
            progress = Progress(totalUnitCount: 1)

            loader.isRequested = true
            enqueueLoadingTask(loader, progress: progress, qualityOfService: .userInitiated)
            nextPresentTransition = transition

            if loader.needsProgressScene {
                presentProgressScene(loader)
            } else if pretransitionScene != nil {
                presentPretransitionScene(loader)
            }
        }
    }

    // MARK: - Utils

    // MARK: Visit scenes

    func visitScene(_ loader: HRT2DSceneLoader, transition: SKTransition? = nil) {
        guard let scene = loader.scene else {
            assertionFailure("scene is not loaded for presentation")
            return
        }

        history.append(loader.info)
        scene.stage = self

        DispatchQueue.main.async {
            self.present(scene, transition: transition ?? self.presentTransition)

            // Reset loading.
            self.progressObservation = nil
            self.enqueueUnloadingTask(for: loader.info)
            loader.reset()
        }
    }

    // MARK: Present scenes

    func presentProgressScene(_ loader: HRT2DSceneLoader) {
        guard progressObservation == nil,
            loader.isRequested
        else { return }

        progressScene.reset()
        progressScene.stage = self
        progressScene.targetSceneInfo = loader.info

        DispatchQueue.main.async {
            self.present(self.progressScene, transition: self.progressPresentTransition)

            self.progressObservation = self.progress?.observe(
                \.fractionCompleted,
                options: [.initial, .new]
            ) { progress, _ in
                DispatchQueue.main.async {
                    self.progressScene.reportProgress(progress, completion: nil)
                }
            }
        }
    }

    func presentPretransitionScene(_ loader: HRT2DSceneLoader) {
        guard let pretransitionScene = pretransitionScene,
            loader.isRequested
        else { return }

        if let prevScene = view.scene as? HRT2DScene,
            let color = prevScene.curtain?.postColor
        {
            pretransitionScene.backgroundColor = color
        } else if let color = view.scene?.backgroundColor {
            pretransitionScene.backgroundColor = color
        }

        DispatchQueue.main.async {
            self.present(pretransitionScene, transition: nil)
        }
    }

    func present(_ scene: HRT2DScene, transition: SKTransition?) {
        let present: HRTBlock = {
            self.input.delegate = scene
            self.view.presentScene(scene, transition: transition)
        }
        if let prevScene = view.scene as? HRT2DScene {
            DispatchQueue.main.async {
                prevScene.prepareToMove(from: self.view) { present() }
            }
        } else {
            DispatchQueue.main.async { present() }
        }
    }

    // MARK: Load and unload tasks

    func enqueueLoadingTask(
        _ loader: HRT2DSceneLoader,
        progress: Progress? = nil,
        qualityOfService: QualityOfService? = nil
    ) {
        if let loadTask = loader.loadTask() {
            let (operation, loaderProgress) = loadTask
            progress?.addChild(loaderProgress, withPendingUnitCount: 1)
            if let operation = operation {
                operation.qualityOfService = qualityOfService ?? operation.qualityOfService
                loadQueue.addOperation(operation)
            }
        }
    }

    func enqueueUnloadingTask(for sceneInfo: HRT2DSceneInfo) {
        loadQueue.addBarrierBlock { self.unloadUnneededAssets(for: sceneInfo) }
    }

    func unloadUnneededAssets(for sceneInfo: HRT2DSceneInfo) {
        // Create list of assets to keep alive (i.e. current and reachable scenes, and their
        // respective dependencies).
        let reachableScenes = script.scenes(reachableFrom: sceneInfo)
        let reachableTypes = reachableScenes.flatMap {
            $0.sceneType.allAssetsLoadingDependencies + [$0.sceneType]
        }
        let keepAlive = Set<ObjectIdentifier>(reachableTypes.map { $0.typeID })

        // Create list of assets to release from memory.
        let unreachableScenes = script.scenes(unreachableFrom: sceneInfo)
        let unneededScenes = unreachableScenes.subtracting(script.isLongLivedScenes)
        let unneededTypes = unneededScenes.flatMap {
            $0.sceneType.allAssetsLoadingDependencies + [$0.sceneType]
        }

        unneededTypes
            .filter { !keepAlive.contains($0.typeID) }
            .forEach { $0.unloadAssets() }
    }

}

// MARK: - HRT2DSceneLoaderDelegate conformance

extension HRT2DStage: HRT2DSceneLoaderDelegate {

    public func sceneLoaderDidLoad(_ sceneLoader: HRT2DSceneLoader, scene: HRT2DScene) {
        guard sceneLoader.isRequested else { return }
        DispatchQueue.main.async {
            self.progressScene.wrapUp {
                self.visitScene(sceneLoader, transition: self.nextPresentTransition)
                self.nextPresentTransition = nil
            }
        }
    }

    public func sceneLoaderDidFail(_ sceneLoader: HRT2DSceneLoader) {
        if progressScene.targetSceneInfo == sceneLoader.info {
            DispatchQueue.main.async { self.progressScene.reportFailure() }
        }
    }

}
