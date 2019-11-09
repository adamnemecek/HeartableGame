// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public protocol HRT2DRenderable: HRTGameEntity {

    associatedtype Facet: HRT2DFacet

    typealias ComponentInfo = [ObjectIdentifier: (facet: Facet, component: HRT2DNoded)]

    var componentInfo: ComponentInfo { get set }

    var nodes: Set<SKNode> { get }

    func addNodedComponent(_ nodedComponent: HRT2DNoded, facet: Facet)

    func removeNodedComponent(_ nodedComponent: HRT2DNoded)

}

public extension HRT2DRenderable {

    var nodes: Set<SKNode> {
        let nodes = componentInfo.values
            .map { $0.component }
            .flatMap { $0.nodes }
        return Set(nodes)
    }

    var renderNode: SKNode {
        component(ofType: HRT2DRenderComponent.self)!.node
    }

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
