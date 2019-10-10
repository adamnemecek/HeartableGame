// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public extension SKTextureAtlas {

    func first<T>(_ direction: T, prefix: String) -> SKTexture where T: HRT2DDirection {
        textureNamed(
            textureNames
                .filter { $0.hasPrefix(prefix) }
                .sorted()
                .first!
        )
    }

}
