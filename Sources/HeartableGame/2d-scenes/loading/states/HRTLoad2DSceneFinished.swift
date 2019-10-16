// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

/// Scene loader state where assets have been loaded into memory.
public class HRTLoad2DSceneFinished: HRTLoad2DSceneState {

    // MARK: - Lifecycle

    public override func didEnter(from previousState: GKState?) {
        loader.postSuccess()
    }

    public override func willExit(to nextState: GKState) {
        loader.cleanUp()
    }

    // MARK: - Functionality

    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is HRTLoad2DSceneInitial.Type: return true
        default: return false
        }
    }

}
