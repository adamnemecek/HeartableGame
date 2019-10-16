// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public protocol HRT2DAssetsLoading: HRTAssetsLoading {

    /// Implementing this property opts into automatic texture loading.
    static var loadableTextures: [SKTexture] { get }

    /// Implementing this property opts into automatic texture atlas loading.
    static var loadableTextureAtlases: [SKTextureAtlas] { get }

}

public extension HRT2DAssetsLoading {

    static var loadableTextures: [SKTexture] { [SKTexture]() }

    static var loadableTextureAtlases: [SKTextureAtlas] { [SKTextureAtlas]() }

    static func load2DAssets(completion: @escaping HRTBlock) {
        SKTexture.preload(loadableTextures) {
            SKTextureAtlas.preloadTextureAtlases(loadableTextureAtlases) {
                completion()
            }
        }
    }

}
