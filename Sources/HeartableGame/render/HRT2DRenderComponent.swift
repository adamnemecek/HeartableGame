// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import SpriteKit

/// Vends a node for rendering.
@available(iOS 10.0, macOS 10.12, *)
open class HRT2DRenderComponent: HRTGameComponent, HRT2DNoded {

    // MARK: - Props

    open private(set) var node = SKNode()

    // MARK: - Lifecycle

    override open func didAddToEntity() {
        super.didAddToEntity()
        entity?.addComponent(GKSKNodeComponent(node: node))
        // Assert that the `GKSKNodeComponent` has correctly set `node`'s `entity`.
        assert(entity === node.entity)
    }

    override open func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        entity?.removeComponent(ofType: GKSKNodeComponent.self)
        // Assert that the `GKSKNodeComponent` has correctly set `node`'s `entity` to nil.
        assert(node.entity == nil)
    }

    // MARK: - Functionality

    /// Adds `node` as a child to the node tree.
    ///
    /// - Parameter node: The node.
    open func render(_ node: SKNode) {
        self.node.addChild(node)
    }

    /// Removes `node` from its node tree.
    ///
    /// - Parameter node: The node.
    open func unrender(_ node: SKNode) {
        node.removeFromParent()
    }

}

@available(iOS 10.0, macOS 10.12, *)
public extension HRT2DRenderComponent {

    var nodes: Set<SKNode> { Set<SKNode>([node]) }

}
