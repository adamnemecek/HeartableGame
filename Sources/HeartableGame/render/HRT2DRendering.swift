// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable
import SpriteKit

@available(iOS 10.0, macOS 10.11, *)
public protocol HRT2DRendering: HRT2DScene {

    // MARK: - Layer

    associatedtype LayerKey: HRT2DLayerKey

    /// The nodes in the scene's node tree to render to.
    var layers: HRTMap<LayerKey, SKNode> { get set }

    /// Constructs `layers`.
    func loadLayers()

    // MARK: - Entity

    /// Adds the entity's facet nodes to the scene's layer nodes as mapped by `link`.
    ///
    /// - Parameters:
    ///     - entity: The entity.
    ///     - link: A type able to map facet to layer.
    func render<T, U>(_ entity: T, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey

    /// Removes the entity's nodes from the scene's node tree.
    ///
    /// - Parameter entity: The entity.
    func unrender<T>(_ entity: T) where T: HRT2DRenderable

    /// Adds the entity to the scene, and adds its facet nodes to the scene's layer nodes as mapped
    /// by `link`.
    ///
    /// - Parameters:
    ///     - entity: The entity.
    ///     - link: A type able to map facet to layer.
    func intro<T, U>(_ entity: T, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey

    /// Removes the entity from the scene, and removes its facet nodes from the scene's layer nodes.
    ///
    /// - Parameter entity: The entity.
    func outro<T>(_ entity: T) where T: HRT2DRenderable

    // MARK: - Component

    /// Adds the component's nodes to the scene's node tree.
    ///
    /// - Parameters:
    ///     - component: The component.
    ///     - layerKey: The key of the layer to render to.
    func render(_ component: HRT2DNoded, layerKey: LayerKey)

    /// Removes the component's nodes from the scene's node tree.
    ///
    /// - Parameter component: The component.
    func unrender(_ component: HRT2DNoded)

    /// Adds the component to `entity`'s `facet` and renders the component.
    ///
    /// - Parameters:
    ///     - component: The component.
    ///     - entity: The entity to add to.
    ///     - facet: The facet of the entity to add to.
    ///     - link: A type able to map facet to layer.
    func intro<T, U>(_ component: HRT2DNoded, to entity: T, facet: T.Facet, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey

    /// Removes and unrenders the component.
    ///
    /// - Parameters:
    ///     - component: The component.
    ///     - entity: The entity to remove from.
    func outro<T>(_ component: HRT2DNoded, from entity: T) where T: HRT2DRenderable

}

@available(iOS 10.0, macOS 10.11, *)
public extension HRT2DRendering {

    // MARK: - Layer impl

    func loadLayers() {
        layers = HRTMap<LayerKey, SKNode> {
            guard let layer = self[$0.path].first else {
                fatalError("Node not found for path: \($0.path)")
            }
            layer.zPosition = $0.zPosition
            return layer
        }
    }

    // MARK: - Entity impl

    func render<T, U>(_ entity: T, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey
    {
        for (facet: facet, component: component) in entity.componentInfo.values {
            let layerKey = U.layerKey(for: facet)
            let layer = layers[layerKey]
            component.nodes.forEach { layer.addChild($0) }
        }
    }

    func unrender<T>(_ entity: T) where T: HRT2DRenderable {
        entity.nodes.forEach { $0.removeFromParent() }
    }

    func intro<T, U>(_ entity: T, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey
    {
        addEntity(entity)
        render(entity, link: link)
    }

    func outro<T>(_ entity: T) where T: HRT2DRenderable {
        removeEntity(entity)
        unrender(entity)
    }

    // MARK: - Component impl

    func render(_ component: HRT2DNoded, layerKey: LayerKey) {
        let layer = layers[layerKey]
        component.nodes.forEach { layer.addChild($0) }
    }

    func unrender(_ component: HRT2DNoded) {
        component.nodes.forEach { $0.removeFromParent() }
    }

    func intro<T, U>(_ component: HRT2DNoded, to entity: T, facet: T.Facet = .default, link: U.Type)
    where T: HRT2DRenderable, U: HRT2DFacetLayerLink, T.Facet == U.Facet, LayerKey == U.LayerKey
    {
        let componentType = type(of: component)
        if let currComponent = entity.component(ofType: componentType) as? HRT2DNoded {
            outro(currComponent, from: entity)
        }
        entity.addNodedComponent(component, facet: facet)
        render(component, layerKey: U.layerKey(for: facet))
        componentSystem(componentType)?.addComponent(component)
    }

    func outro<T>(_ component: HRT2DNoded, from entity: T) where T: HRT2DRenderable {
        entity.removeNodedComponent(component)
        unrender(component)
        componentSystem(type(of: component))?.removeComponent(component)
    }

}
