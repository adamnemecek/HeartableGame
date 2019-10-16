// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

/// Scene loader state where assets are ready to be loaded into memory.
public class HRTLoad2DSceneReady: HRTLoad2DSceneState {

    // MARK: - Functionality

    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is HRTLoad2DSceneInitial.Type,
             is HRTLoad2DSceneLoading.Type:
            return true
        default: return false
        }
    }

}
