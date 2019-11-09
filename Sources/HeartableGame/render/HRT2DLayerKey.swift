// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics
import Foundation
import SpriteKit

public protocol HRT2DLayerKey: HRT2DNodeKey {

    static var `default`: Self { get }

    var zPosition: CGFloat { get }

}

public extension HRT2DLayerKey {

    func getOrCreate(in scene: HRT2DScene) -> SKNode {
        guard let node = scene[path].first else {
            let parentNode = parent?.getOrCreate(in: scene) ?? scene
            let node = SKNode()
            node.name = name
            node.zPosition = zPosition
            parentNode.addChild(node)
            return node
        }
        return node
    }

}

public extension HRT2DLayerKey where Self: RawRepresentable, Self.RawValue == CGFloat {

    var zPosition: CGFloat { self.rawValue }

}
