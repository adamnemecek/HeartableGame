// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

@available(iOS 10.0, macOS 10.11, *)
public extension HRT2DRendering where Self: HRTSelfMaking, Self: HRTTypeSized {

    func loadLayers() {
        layers = HRTMap<LayerKey, SKNode> {
            guard let layer = self[$0.path].first else {
                let node = SKNode()
                node.name = $0.name
                node.zPosition = $0.zPosition
                addChild(node)
                return node
            }
            layer.zPosition = $0.zPosition
            return layer
        }
    }

}
