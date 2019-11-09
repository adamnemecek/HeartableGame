// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import GameplayKit

class HRT2DSceneCurtainState: GKState {

    // MARK: - Props

    unowned let scene: HRT2DScene

    // MARK: - Init

    init(_ scene: HRT2DScene) {
        self.scene = scene
        super.init()
    }

}
