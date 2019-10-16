// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit
import Heartable

/// Scene loader state where assets being loaded into memory.
public class HRTLoad2DSceneLoading: HRTLoad2DSceneState {

    // MARK: Attrs

    public private(set) lazy var operationQueue: HRTOperationQueue = {
        let queue = HRTOperationQueue()
        queue.name = "\(Self.self).sceneLoadingQueue"
        queue.qualityOfService = .utility
        return queue
    }()

    public private(set) lazy var assetsLoader: HRTAssetsLoader = {
        let assetsLoader = HRTAssetsLoader(loader.info.sceneType)
        assetsLoader.qualityOfService = .utility
        return assetsLoader
    }()

    public private(set) var progress: Progress?

    // MARK: - Lifecycle

    public override func didEnter(from previousState: GKState?) {
        loader.isRequested ? raisePriority() : lowerPriority()
        load()
    }

    // MARK: - Functionality

    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is HRTLoad2DSceneInitial.Type, is HRTLoad2DSceneReady.Type: return true
        case is HRTLoad2DSceneFinished.Type: return loader.scene != nil
        default: return false
        }
    }

    public func raisePriority() {
        operationQueue.qualityOfService = .userInitiated
        assetsLoader.qualityOfService = .userInitiated
    }

    public func lowerPriority() {
        operationQueue.qualityOfService = .utility
        assetsLoader.qualityOfService = .utility
    }

    public func cancel() {
        operationQueue.cancelAllOperations()
        assetsLoader.cancel()
    }

    // MARK: - Utils

    func load() {
        // Set up progress. Give equal weight to each asset to load, plus scene loading.
        let assetTypesCount = Int64(assetsLoader.loadingTypes.count)
        let progress = Progress(totalUnitCount: assetTypesCount + 1)
        self.progress = progress
        loader.progress?.addChild(progress, withPendingUnitCount: 1)

        // Set up operation to load assets (including scene assets).
        let loadSceneAssetsOperation = HRTBlockOperation({ completion in
            let assetsLoadingProgress = self.assetsLoader.load {
                if $0 == .failure {
                    DispatchQueue.main.async { self.cancel() }
                }
                completion()
            }
            progress.addChild(assetsLoadingProgress, withPendingUnitCount: assetTypesCount)
        })

        // Set up operation for scene initialization.
        let loadSceneOperation = HRTLoad2DSceneOperation(loader.info)
        loadSceneOperation.addSubscriber(HRTBlockSubscriber { operation, errors in
            if !operation.isCancelled,
                errors.isEmpty,
                let scene = loadSceneOperation.scene
            {
                DispatchQueue.main.async {
                    self.loader.scene = scene
                    let didEnterState = self.loader.stateMachine.enter(HRTLoad2DSceneFinished.self)
                    assert(didEnterState)
                }
            } else {
                // If the assets-loading operation had failures, this operation would've been
                // cancelled. This is considered a failure in loading.
                DispatchQueue.main.async {
                    self.loader.cleanUp()
                    let didEnterState = self.loader.stateMachine.enter(HRTLoad2DSceneReady.self)
                    assert(didEnterState)
                    self.loader.postFailure()
                }
            }
        })

        loadSceneOperation.addDependency(loadSceneAssetsOperation)
        progress.addChild(loadSceneOperation.progress, withPendingUnitCount: 1)
        operationQueue.addOperations([loadSceneAssetsOperation, loadSceneOperation])
    }

}
