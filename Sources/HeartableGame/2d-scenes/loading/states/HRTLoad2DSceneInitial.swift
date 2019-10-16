// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

/// The scene loader's initial state. Allows for branching to non-cross-platform states.
public class HRTLoad2DSceneInitial: HRTLoad2DSceneState {

    // MARK: - Lifecycle

    public override func didEnter(from previousState: GKState?) {
        loader.cleanUp()
        // TODO: Add branching logic. For now, transition immediately to the next state.
        stateMachine?.enter(HRTLoad2DSceneReady.self)
    }

    // MARK: - Functionality

    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is HRTLoad2DSceneReady.Type
    }

}
