// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import SpriteKit

public protocol HRT2DNodeKey: CaseIterable, Hashable {

    init?(name: String)

    var name: String { get }

    var path: String { get }

    var parent: Self? { get }

    func getOrCreate(in scene: HRT2DScene) -> SKNode

}

public extension HRT2DNodeKey {

    init?(name: String) {
        guard let key = Self.allCases.first(where: { $0.name == name }) else { return nil }
        self = key
    }

    var name: String { String(describing: self) }

    var path: String {
        guard let parent = parent else { return name }
        return "\(parent.path)/\(name)"
    }

    var parent: Self? { nil }

    func getOrCreate(in scene: HRT2DScene) -> SKNode {
        guard let node = scene[path].first else {
            let parentNode = parent?.getOrCreate(in: scene) ?? scene
            let node = SKNode()
            node.name = name
            parentNode.addChild(node)
            return node
        }
        return node
    }

}

public extension HRT2DNodeKey where Self: RawRepresentable, Self.RawValue == String {

    init?(name: String) {
        self.init(rawValue: name)
    }

    var name: String { rawValue }

}
