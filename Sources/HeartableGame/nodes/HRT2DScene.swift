// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable
import SpriteKit

@available(iOS 10.0, macOS 10.11, *)
open class HRT2DScene: SKScene, HRTEponymous, HRTGameplayBased {

    // MARK: - Props

    // MARK: State

    public var lastUpdateTime: TimeInterval = 0

    // MARK: Entity-component design

    open var entities = Set<GKEntity>()

    open var componentSystems = [ObjectIdentifier: GKComponentSystem<GKComponent>]()

    // MARK: - Lifecycle

    override open func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime <= 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update component systems.
        componentSystems.values.forEach { $0.update(deltaTime: deltaTime) }

        // Update entities.
        entities.forEach { $0.update(deltaTime: deltaTime) }
    }

    // MARK: - Functionality

    // MARK: Entity

    open func addEntity(_ entity: GKEntity) {
        entities.insert(entity)
        componentSystems.values.forEach { $0.addComponent(foundIn: entity) }
    }

    open func removeEntity(_ entity: GKEntity) {
        entities.remove(entity)
        componentSystems.values.forEach { $0.removeComponent(foundIn: entity) }
    }

    // MARK: Component

    open func componentSystem<T>(_ componentClass: T.Type) -> GKComponentSystem<T>? {
        let system = componentSystems[ObjectIdentifier(componentClass)]
        return system as? GKComponentSystem<T>
    }

    open func addComponent(_ component: GKComponent, to entity: GKEntity) {
        let componentType = type(of: component)
        if let currComponent = entity.component(ofType: componentType) {
            removeComponent(currComponent, from: entity)
        }
        entity.addComponent(component)
        componentSystem(componentType)?.addComponent(component)
    }

    open func removeComponent(_ component: GKComponent, from entity: GKEntity) {
        let componentType = type(of: component)
        entity.removeComponent(ofType: componentType)
        componentSystem(componentType)?.removeComponent(component)
    }

}
