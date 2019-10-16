// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

/// Handles the animation aspect of an entity.
///
/// - Important: Requires the entity to have a render component and a rotation component.
public class HRT2DAnimationComponent<Variant, Direction, Facet>: HRTGameComponent
where Variant: HRT2DAnimationVariant, Direction: HRT2DDirection, Facet: HRT2DFacet
{

    public typealias AnimationUnit = HRT2DAnimationUnit<Variant, Direction, Facet>
    public typealias AnimationUnits = HRTMap<Variant, HRTMap<Direction, AnimationUnit>>

    public static var animationKey: String { "\(self).animation" }

    // MARK: - Props

    // MARK: Config

    /// The current animation variant.
    public var variant: Variant = .default {
        didSet { shouldChangeAnimation = true }
    }

    // MARK: State

    /// Info about current animation.
    public private(set) var unit: AnimationUnit?

    /// True iff the animation should be changed in the next update.
    private var shouldChangeAnimation = true

    /// Duration that the current animation has been playing. Used for deriving the frame offset.
    private var elapsedDuration: TimeInterval = 0

    // MARK: Attrs

    /// The main animation node.
    public private(set) var node: SKSpriteNode

    /// Mapping from facets to nodes.
    public let facetNodes: [Facet: SKNode]

    /// Info on all associated animations.
    public let units: AnimationUnits

    /// The associated render component.
    public var renderComponent: HRT2DRenderComponent? {
        entity?.component(ofType: HRT2DRenderComponent.self)
    }

    /// The associated rotation component.
    public var rotationComponent: HRT2DRotationComponent<Direction>? {
        entity?.component(ofType: HRT2DRotationComponent<Direction>.self)
    }

    // MARK: - Init

    public init(
        size: CGSize,
        units: AnimationUnits,
        facetNodes: [Facet: SKNode]
    ) {
        node = SKSpriteNode(texture: nil, size: size)
        self.units = units
        self.facetNodes = facetNodes
        super.init()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    open override func didAddToEntity() {
        super.didAddToEntity()
        renderComponent?.render(node)
    }

    open override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        node.removeFromParent()
    }

    open override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        if shouldChangeAnimation,
            let direction = rotationComponent?.direction
        {
            shouldChangeAnimation = false
            animate(variant, direction: direction, deltaTime: seconds)
        }
    }

    // MARK: - Functionality

    private func animate(_ variant: Variant, direction: Direction, deltaTime seconds: TimeInterval) {
        elapsedDuration += seconds

        guard unit?.variant != variant || unit?.direction != direction
        else { return }

        var newUnit = units[variant][direction]

        // Check if each facet's action should change.
        for (facet, (actionName, action)) in newUnit.facetActions {
            if let facetNode = facetNodes[facet],
                actionName != unit?.facetActions[facet]?.actionName
            {
                // Remove existing action.
                facetNode.removeAction(forKey: facet.stringValue)

                // Reset geometry.
                facetNode.position = .zero
                facetNode.xScale = 1
                facetNode.yScale = 1

                // Add new action.
                facetNode.run(action.repeated(newUnit.repeatCount), withKey: facet.stringValue)
            }
        }

        // Main animation

        // Remove existing main animation.
        node.removeAction(forKey: Self.animationKey)

        // Create main animation.
        let animation: SKAction
        if newUnit.textures.count == 1 {
            animation = SKAction.setTexture(newUnit.textures.first!)
        } else {
            if let unit = unit, newUnit.variant == unit.variant {
                // Only the direction has changed. To preserve continuity, start the new animation
                // from the current offset of the current animation.
                let playedFramesCount = Int(elapsedDuration / unit.timePerFrame)
                let rawNewOffset = unit.frameOffset + playedFramesCount + 1
                let newOffset = rawNewOffset % unit.textures.count
                newUnit.frameOffset = newOffset
            }
            animation = newUnit.animation
        }

        // Run main animation.
        node.run(animation, withKey: Self.animationKey)

        // Update state.
        unit = newUnit
        elapsedDuration = 0
    }

}
