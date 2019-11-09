// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

class HRT2DSceneClosed: HRT2DSceneCurtainState {

    // MARK: - Lifecycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        scene.exitCompletion?()
        scene.exitCompletion = nil
    }

}
