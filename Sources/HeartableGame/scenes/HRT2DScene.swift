// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable
import SpriteKit

@available(iOS 9.0, *)
open class HRT2DScene: SKScene, HRTGameplayBased {

    // MARK: - Props

    // MARK: State

    var lastUpdateTime: TimeInterval = 0

    // MARK: Entity-component design

    open var entities = Set<GKEntity>()

    open var removedEntities = Set<GKEntity>()

    public let componentSystems = [GKComponentSystem]()

    // MARK: - Lifecycle

    override open func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime <= 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update component systems.
        componentSystems.forEach { $0.update(deltaTime: deltaTime) }

        // Remove components of removed entities from component systems.
        for removedEntity in removedEntities {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: removedEntity)
            }
        }
        removedEntities.removeAll()

        // Update entities.
        entities.forEach { $0.update(deltaTime: deltaTime) }
    }

    // MARK: - Functionality

    // MARK: Entity

    func add(_ entity: GKEntity) {
        guard !entities.contains(entity) else { return }
        if let nodeBasedEntity = entity as? HRT2DNodeBased {
            for node in nodeBasedEntity.nodes {
                addChild(node)
            }
        }
        entities.insert(entity)
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }

    func remove(_ entity: GKEntity) {
        guard entities.contains(entity) else { return }
        if let nodeBasedEntity = entity as? HRT2DNodeBased {
            removeChildren(in: Array(nodeBasedEntity.nodes))
        }
        entities.remove(entity)
        removedEntities.insert(entity)
    }

}
