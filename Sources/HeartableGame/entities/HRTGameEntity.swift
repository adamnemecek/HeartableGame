// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable

open class HRTGameEntity: GKEntity {

    open weak var hrt2DScene: HRT2DScene?

    open func didMove(to scene: HRT2DScene) {
        hrt2DScene = scene
        components
            .compactMap { $0 as? HRTGameComponent }
            .forEach { $0.didMove(to: scene) }
    }

    open func willMove(from scene: HRT2DScene) {
        hrt2DScene = nil
        components
            .compactMap { $0 as? HRTGameComponent }
            .forEach { $0.willMove(from: scene) }
    }

    open func didMove(to view: SKView) {}

    open func willMove(from view: SKView) {}

}
