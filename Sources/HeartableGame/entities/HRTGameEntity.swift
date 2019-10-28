// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit

open class HRTGameEntity: GKEntity {

    open func didMove(to scene: HRT2DScene) {
        components
            .compactMap { $0 as? HRTGameComponent }
            .forEach { $0.didMove(to: scene) }
    }

    open func willMove(from scene: HRT2DScene) {
        components
            .compactMap { $0 as? HRTGameComponent }
            .forEach { $0.willMove(from: scene) }
    }

}
