// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import GameplayKit

public class HRT2DSceneLoader {

    // MARK: - Props

    public weak var delegate: HRT2DSceneLoaderDelegate?

    /// Tracks the scene loader's state.
    private(set) lazy var stateMachine = GKStateMachine(states: [
        HRTLoad2DSceneInitial(governing: self),
        HRTLoad2DSceneReady(governing: self),
        HRTLoad2DSceneLoading(governing: self),
        HRTLoad2DSceneFinished(governing: self)
    ])

    /// Info on the scene to load.
    public let info: HRT2DSceneInfo

    /// The scene to load. If nil, indicates it has not yet been successfully loaded.
    public internal(set) var scene: HRT2DScene?

    /// Progress tracking scene loading. If nil, indicates no loading is taking place.
    public internal(set) var progress: Progress?

    /// Completion handler to be called when loading is complete.
    public internal(set) var loadCompletion: HRT2DSceneLoaderResultBlock?

    // MARK: - State

    /// Set to true to raise loading priority, and false to lower.
    public var isRequested = false {
        didSet {
            guard let loadingState = stateMachine.currentState as? HRTLoad2DSceneLoading
            else { return }
            isRequested ? loadingState.raisePriority() : loadingState.lowerPriority()
        }
    }

    /// True iff a progress scene should be presented while loading the scene.
    public var needsProgressScene: Bool {
        info.showsLoading &&
        (
            info.sceneType.shouldLoadAssets
            || info.sceneType.assetsLoadingDependencies.contains { $0.shouldLoadAssets }
        )
    }

    /// True iff the loader is in the finished state.
    public var isFinished: Bool { stateMachine.currentState is HRTLoad2DSceneFinished }

    /// True iff the loader has been cancelled.
    public internal(set) var isCancelled = false

    // MARK: - Init

    public init(_ info: HRT2DSceneInfo) {
        self.info = info

        stateMachine.enter(HRTLoad2DSceneInitial.self)
    }

    // MARK: - Functionality

    /// Loads the scene.
    ///
    /// - Parameter completion: Completion handler for when the scene is loaded.
    /// - Returns: The progress object tracking this loading operation.
    @discardableResult
    public func load(completion: HRT2DSceneLoaderResultBlock? = nil) -> Progress? {
        guard !isCancelled else {
            postFailure()
            return nil
        }

        if let progress = progress,
            !progress.isCancelled
        {
            // Loading is already in progress.
            completion?(.ongoing)
            return progress
        }

        loadCompletion = completion

        switch stateMachine.currentState {
        case is HRTLoad2DSceneReady:
            progress = Progress(totalUnitCount: 1)
            stateMachine.enter(HRTLoad2DSceneLoading.self)
            return progress
        default:
            // TODO: Handle unexpected states.
            postFailure()
            return nil
        }
    }

    public func cancel() {
        isCancelled = true
        (stateMachine.currentState as? HRTLoad2DSceneLoading)?.cancel()
    }

    /// Releases loaded resources and brings the loader back to its initial state.
    public func reset() {
        cancel()
        cleanUp()
        stateMachine.enter(HRTLoad2DSceneInitial.self)
    }

    // MARK: - Utils

    func postSuccess() {
        guard let scene = scene else { fatalError("Scene \(info.sceneType) failed to load") }
        loadCompletion?(.success(scene))
        delegate?.sceneLoaderDidLoad(self, scene: scene)
    }

    func postFailure() {
        loadCompletion?(.failure)
        delegate?.sceneLoaderDidFail(self)
    }

    func cleanUp() {
        scene = nil
        progress?.cancel()
        isRequested = false
        isCancelled = false
    }

}
