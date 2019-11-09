// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DSpriteEntity: HRTGameEntity, HRT2DRenderable {

    // MARK: - Types

    public typealias Facet = HRT2DUniFacet

    // MARK: - Props

    open var componentInfo = ComponentInfo()

    open var spriteNode: SKSpriteNode {
        didSet {
            oldValue.removeFromParent()
            renderNode.addChild(spriteNode)
        }
    }

    // MARK: - Init

    public init(_ spriteNode: SKSpriteNode) {
        self.spriteNode = spriteNode
        super.init()

        let renderComponent = HRT2DRenderComponent()
        addNodedComponent(renderComponent)

        spriteNode.removeFromParent()
        renderComponent.node.addChild(spriteNode)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
