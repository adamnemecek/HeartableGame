// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import SpriteKit

public extension SKView {

    func presentScene(_ scene: HRT2DScene, transition: SKTransition? = nil) {
        if let transition = transition {
            presentScene(scene, transition: transition)
        } else {
            presentScene(scene as SKScene)
        }
    }

}
