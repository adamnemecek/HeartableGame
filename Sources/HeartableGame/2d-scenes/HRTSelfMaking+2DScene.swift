// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import GameplayKit
import SpriteKit

public extension HRTSelfMaking where Self: SKScene & HRTTypeSized {
    static func make() -> Self {
        let scene = Self(size: typeSize)
        scene.scaleMode = .aspectFill
        return scene
    }
}

public extension HRTSelfMaking where Self: SKScene & HRTFileBased {
    static func make() -> Self {
        let scene = Self(fileNamed: fileName)!
        scene.scaleMode = .aspectFill
        return scene
    }
}

public extension HRTSelfMaking where Self: SKScene & HRTFileBased & HRTGameplayBased {
    static func make() -> Self {
        let sceneContainer = GKScene(fileNamed: fileName)!
        var scene = sceneContainer.rootNode as! Self
        scene.entities.formUnion(sceneContainer.entities)
        scene.scaleMode = .aspectFill
        return scene
    }
}
