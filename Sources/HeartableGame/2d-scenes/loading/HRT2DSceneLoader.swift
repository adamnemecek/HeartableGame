// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
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
    public var needsProgressScene: Bool { info.sceneChange }

    /// True iff the loader is in the finished state.
    public var isFinished: Bool { stateMachine.currentState is HRTLoad2DSceneFinished }

    // MARK: - Init

    public init(_ info: HRT2DSceneInfo) {
        self.info = info

        stateMachine.enter(HRTLoad2DSceneInitial.self)
    }

    // MARK: - Functionality

    /// Load the scene.
    ///
    /// - Returns: The progress of the loading.
    @discardableResult
    public func load() -> Progress {
        if let progress = progress,
            !progress.isCancelled
        {
            // Loading is already in progress.
            return progress
        }

        switch stateMachine.currentState {
        case is HRTLoad2DSceneReady:
            progress = Progress(totalUnitCount: 1)
            stateMachine.enter(HRTLoad2DSceneLoading.self)
        default:
            // TODO: Handle unexpected states.
            break
        }

        return progress ?? Progress(totalUnitCount: 0)
    }

    public func cancel() {
        guard let loadingState = stateMachine.currentState as? HRTLoad2DSceneLoading else { return }
        loadingState.cancel()
    }

    /// Releases loaded resources and brings the loader back to its initial state.
    public func reset() {
        cancel()
        cleanUp()
        stateMachine.enter(HRTLoad2DSceneInitial.self)
    }

    // MARK: - Utils

    func postSuccess() {
        guard let scene = scene else { fatalError("Scene \(info.sceneType) failed to load.") }
        delegate?.sceneLoaderDidLoad(self, scene: scene)
    }

    func postFailure() {
        delegate?.sceneLoaderDidFail(self)
    }

    func cleanUp() {
        scene = nil
        progress?.cancel()
        isRequested = false
    }

}
