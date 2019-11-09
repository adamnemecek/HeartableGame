// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

class HRT2DSceneClosing: HRT2DSceneCurtainState {

    // MARK: - Lifecycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        if let curtain = scene.curtain {
            curtain.close() { self.stateMachine?.enter(HRT2DSceneClosed.self) }
        } else {
            stateMachine?.enter(HRT2DSceneClosed.self)
        }
    }

}
