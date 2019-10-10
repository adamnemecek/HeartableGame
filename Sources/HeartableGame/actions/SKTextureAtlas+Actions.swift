// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public extension SKTextureAtlas {

    func loopAction(_ count: Int = 0, timePerFrame: TimeInterval = 0.1) -> SKAction {
        let textures = textureNames.sorted().map { textureNamed($0) }
        if textures.count == 1 {
            return SKAction.setTexture(textures.first!)
        } else {
            return SKAction.animate(with: textures, timePerFrame: timePerFrame).repeated(count)
        }
    }

}
