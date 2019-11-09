// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

class HRT2DSceneOpening: HRT2DSceneCurtainState {

    // MARK: - Lifecycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        if let curtain = scene.curtain {
            curtain.open() { self.stateMachine?.enter(HRT2DSceneOpened.self) }
        } else {
            stateMachine?.enter(HRT2DSceneOpened.self)
        }
    }

}
