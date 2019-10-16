// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

/// Holds info about a semantic grouping of animations.
public struct HRT2DAnimationUnit<Variant, Direction, Facet>
where Variant: HRT2DAnimationVariant, Direction: HRT2DDirection, Facet: HRT2DFacet
{

    public typealias FacetActions = [Facet: (actionName: String, action: SKAction)]

    // MARK: - Creational

    public static func directionedUnits(
        for variant: Variant,
        from atlas: SKTextureAtlas,
        makePrefix: (Direction) -> String,
        repeatCount: Int = 0,
        reversed: Bool = false,
        fps: Int = 10,
        facetActions: FacetActions = [:]
    ) -> HRTMap<Direction, Self> {
        return HRTMap<Direction, Self> { direction in
            let textures = atlas.textureNames
                .filter { $0.hasPrefix(makePrefix(direction)) }
                .sorted { reversed ? $0 > $1 : $0 < $1 }
                .map { atlas.textureNamed($0) }
            return Self(
                variant: variant,
                direction: direction,
                textures: textures,
                repeatCount: repeatCount,
                fps: fps,
                facetActions: facetActions
            )
        }
    }

    // MARK: - Props

    /// The variant of this animation unit.
    public let variant: Variant

    /// The semantics of this animation unit's rotation.
    public let direction: Direction

    /// The main animating textures.
    public let textures: [SKTexture]

    /// The number of times to repeat the animation. If 0, repeats forever.
    @HRTAtLeast(0) public private(set) var repeatCount: Int = 0

    /// Number of frames per second.
    public let fps: Int

    /// Mapping of facets to actions.
    public let facetActions: FacetActions

    /// Index of the texture in `textures` to use as the first frame. Stateful.
    public var frameOffset = 0

}

public extension HRT2DAnimationUnit {

    /// Seconds per frame.
    var timePerFrame: TimeInterval { 1.0 / Double(fps) }

    /// Rotated copy of `textures` where the texture at `frameOffset` is at the start.
    var offsetTextures: [SKTexture] {
        guard frameOffset > 0 && frameOffset < textures.count else {
            return textures
        }
        return Array(textures[frameOffset...] + textures[..<frameOffset])
    }

    /// Animation action derived from this unit.
    var animation: SKAction {
        SKAction.animate(with: offsetTextures, timePerFrame: timePerFrame).repeated(repeatCount)
    }

}
