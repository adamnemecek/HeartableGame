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

    /// The presenting view.
    public let view: SKView

    /// Player control input.
    public let input: HRT2DGameInput

    /// Content authority.
    public let script: HRT2DScript

    // MARK: Loading

    /// Loaders for all scenes.
    public let sceneLoaders: [HRT2DSceneInfo: HRT2DSceneLoader]

    /// Scene indicating loading progress.
    private(set) lazy var progressScene: HRT2DProgressScene = {
        let scene = progressSceneType.make()
        scene.stage = self
        return scene
    }()

    // MARK: State

    /// Scene currently presented.
    private var currSceneInfo: HRT2DSceneInfo?

    /// Observation token for tracking loading progress.
    private var progressObservation: NSKeyValueObservation?

    // MARK: Config

    public var progressSceneType: HRT2DProgressScene.Type = HRT2DProgressScene.self {
        didSet {
            progressScene = progressSceneType.make()
            progressScene.stage = self
        }
    }

    public var presentTransition: SKTransition?

    public var progressPresentTransition: SKTransition?

    // MARK: - Init

    public init(_ view: SKView, input: HRT2DGameInput, script: HRT2DScript) {
        self.view = view
        self.input = input
        self.script = script

        sceneLoaders = Dictionary(uniqueKeysWithValues: script.scenesGraph.keys.map {
            ($0, HRT2DSceneLoader($0))
        })
        sceneLoaders.values.forEach { $0.delegate = self }
    }

    // MARK: - Functionality

    public var nextScenes: Set<HRT2DSceneInfo> {
        guard let curr = currSceneInfo else { return [script.openingScene] }
        return script.scenes(after: curr)
    }

    public func prepareNextScenes() {
        script.scenes(after: currSceneInfo ?? script.openingScene).forEach { prepareScene($0) }
    }

    public func prepareScene(_ sceneInfo: HRT2DSceneInfo) {
        guard let loader = sceneLoaders[sceneInfo] else {
            assertionFailure("Not a staged scene: \(sceneInfo).")
            return
        }
        loader.load()
    }

    public func transition(to sceneInfo: HRT2DSceneInfo, transition: SKTransition? = nil) {
        guard let loader = sceneLoaders[sceneInfo] else {
            assertionFailure("Not a staged scene: \(sceneInfo).")
            return
        }

        if loader.isFinished {
            presentScene(loader, transition: transition)
        } else {
            loader.load()
            loader.isRequested = true
            if loader.needsProgressScene {
                presentProgressScene(loader)
            }
        }
    }

    // MARK: - Utils

    func presentScene(_ loader: HRT2DSceneLoader, transition: SKTransition? = nil) {
        guard let scene = loader.scene else {
            assertionFailure("Scene is not loaded for presentation.")
            return
        }

        currSceneInfo = loader.info
        scene.stage = self

        DispatchQueue.main.async {
            if let transition = transition ?? self.presentTransition {
                self.view.presentScene(scene, transition: transition)
            } else {
                self.view.presentScene(scene)
            }

            // Release unneeded resources.
            self.progressObservation = nil
            loader.reset()
            self.releaseUnreachableScenes()
        }
    }

    func presentProgressScene(_ loader: HRT2DSceneLoader) {
        guard progressObservation == nil else { return }

        progressScene.reset()
        progressScene.stage = self
        progressScene.targetSceneInfo = loader.info

        DispatchQueue.main.async {
            guard loader.isRequested else { return }

            if let transition = self.progressPresentTransition {
                self.view.presentScene(self.progressScene, transition: transition)
            } else {
                self.view.presentScene(self.progressScene)
            }

            self.progressObservation = loader.progress?.observe(
                \.fractionCompleted,
                options: [.initial, .new]
            ) { progress, _ in
                DispatchQueue.main.async {
                    self.progressScene.reportProgress(progress)
                }
            }
        }
    }

    func releaseUnreachableScenes() {
        script.scenes(unreachableFrom: currSceneInfo ?? script.openingScene).forEach {
            sceneLoaders[$0]?.reset()
        }
    }

}

extension HRT2DStage: HRT2DSceneLoaderDelegate {

    public func sceneLoaderDidLoad(_ sceneLoader: HRT2DSceneLoader, scene: HRT2DScene) {
        if sceneLoader.isRequested {
            progressScene.wrapUp {
                self.presentScene(sceneLoader)
                sceneLoader.isRequested = false
            }
        }
    }

    public func sceneLoaderDidFail(_ sceneLoader: HRT2DSceneLoader) {
        if progressScene.targetSceneInfo == sceneLoader.info {
            progressScene.reportFailure()
        }
    }

}
