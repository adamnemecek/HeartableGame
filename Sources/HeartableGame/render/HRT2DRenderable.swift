// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public protocol HRT2DRenderable: HRTGameEntity {

    // MARK: - Types

    associatedtype Facet: HRT2DFacet

    typealias ComponentInfo = [ObjectIdentifier: (facet: Facet, component: HRT2DNoded)]

    // MARK: - Props

    var componentInfo: ComponentInfo { get set }

    var nodes: Set<SKNode> { get }

    var renderNode: SKNode { get }

    // MARK: - Functionality

    func addNodedComponent(_ nodedComponent: HRT2DNoded, facet: Facet)

    func removeNodedComponent(_ nodedComponent: HRT2DNoded)

}

public extension HRT2DRenderable {

    // MARK: - Props impl

    var nodes: Set<SKNode> {
        let nodes = componentInfo.values
            .map { $0.component }
            .flatMap { $0.nodes }
        return Set(nodes)
    }

    var renderNode: SKNode {
        guard let node = component(ofType: HRT2DRenderComponent.self)?.node else {
            fatalError("\(Self.self) does not have a \(HRT2DRenderComponent.self)")
        }
        return node
    }

    // MARK: - Functionality impl

    func addNodedComponent(_ nodedComponent: HRT2DNoded, facet: Facet = .default) {
        addComponent(nodedComponent)
        let key = ObjectIdentifier(type(of: nodedComponent))
        let value = (facet: facet, component: nodedComponent)
        componentInfo[key] = value
    }

    func removeNodedComponent(_ nodedComponent: HRT2DNoded) {
        let componentType = type(of: nodedComponent)
        removeComponent(ofType: componentType)
        componentInfo.removeValue(forKey: ObjectIdentifier(componentType))
    }

}
