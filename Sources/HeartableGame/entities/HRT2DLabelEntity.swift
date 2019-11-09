// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DLabelEntity: HRTGameEntity, HRT2DRenderable {

    // MARK: - Types

    public typealias Facet = HRT2DUniFacet

    // MARK: - Props

    open var componentInfo = ComponentInfo()

    @HRTLate open var labelNode: SKLabelNode

    open var textStyle: HRTStringStyling {
        didSet { text = labelNode.attributedText?.string }
    }

    open var text: String? {
        get { labelNode.attributedText?.string }
        set {
            if let newText = newValue {
                labelNode.attributedText = newText.style(textStyle)
            } else {
                labelNode.attributedText = nil
            }
        }
    }

    // MARK: - Init

    public init(_ textStyle: HRTStringStyling, labelNode: SKLabelNode? = nil) {
        self.textStyle = textStyle
        super.init()

        // Render component
        let renderComponent = HRT2DRenderComponent()
        addNodedComponent(renderComponent)

        self.labelNode = labelNode ?? SKLabelNode()
        self.labelNode.removeFromParent()
        renderComponent.node.addChild(self.labelNode)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - HRT2DProgressLabeling conformance

extension HRT2DLabelEntity: HRT2DProgressLabeling {}
