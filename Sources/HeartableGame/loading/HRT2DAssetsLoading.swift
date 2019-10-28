// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public protocol HRT2DAssetsLoading: HRTAssetsLoading {

    /// Implementing this property opts into automatic texture loading.
    static var textureNames: [String] { get }

    /// Implementing this property opts into automatic texture atlas loading.
    static var textureAtlasNames: [String] { get }

}

public extension HRT2DAssetsLoading {

    static var textureNames: [String] { [] }

    static var textureAtlasNames: [String] { [] }

    static func load2DAssets(
        completion: @escaping ([String: SKTexture], [String: SKTextureAtlas]) -> Void
    ) {
        let textures = Dictionary(textureNames.map { ($0, SKTexture(imageNamed: $0)) }) {
            _, last in last
        }

        let textureAtlases = Dictionary(textureAtlasNames.map { ($0, SKTextureAtlas(named: $0)) }) {
            _, last in last
        }

        SKTexture.preload(Array(textures.values)) {
            SKTextureAtlas.preloadTextureAtlases(Array(textureAtlases.values)) {
                completion(textures, textureAtlases)
            }
        }
    }

}
