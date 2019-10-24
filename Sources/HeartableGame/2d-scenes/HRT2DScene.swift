// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable
import SpriteKit

open class HRT2DScene: SKScene, HRTEponymous, HRTGameplayBased, HRT2DAssetsLoading {

    // MARK: - Type props

    public class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }

    // MARK: - Type functionality

    public class func loadAssets(completion: @escaping HRTBlock) {
        load2DAssets { completion() }
    }

    // MARK: - Props

    open weak var stage: HRT2DStage? {
        didSet { stage?.input.delegate = self }
    }

    open var overlay: HRT2DOverlay? {
        didSet {
            if let overlay = overlay,
                let camera = camera
            {
                overlay.attach(to: camera)
            }
            oldValue?.detach()
        }
    }

    open var entities = Set<GKEntity>()

    open var componentSystems = [ObjectIdentifier: GKComponentSystem<GKComponent>]()

    // MARK: State

    public var lastUpdateTime: TimeInterval = 0

    // MARK: Config

    /// The initial reference point for the camera.
    open var initialPoint: CGPoint = .zero

    // MARK: - Lifecycle

    open override func sceneDidLoad() {
        super.sceneDidLoad()
        if camera == nil { setUpCamera() }
    }

    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        overlay?.rescale()
    }

    open override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        overlay?.rescale()
    }

    override open func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime <= 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update component systems.
        componentSystems.values.forEach { $0.update(deltaTime: deltaTime) }

        // Update entities.
        entities.forEach { $0.update(deltaTime: deltaTime) }
    }

    // MARK: - Functionality

    // MARK: Entities

    open func addEntity(_ entity: GKEntity) {
        entities.insert(entity)
        componentSystems.values.forEach { $0.addComponent(foundIn: entity) }
    }

    open func removeEntity(_ entity: GKEntity) {
        entities.remove(entity)
        componentSystems.values.forEach { $0.removeComponent(foundIn: entity) }
    }

    // MARK: Components

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

    // MARK: Camera

    open func setUpCamera() {
        camera?.removeFromParent()
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
    }

    open func placeCamera(at point: CGPoint) {
        camera?.position = point
    }

}

// MARK: - HRT2DGameInputDelegate conformance

extension HRT2DScene: HRT2DGameInputDelegate {

    public func inputDidUpdateSources(_ input: HRT2DGameInput) {
        input.sources.forEach { $0.gameDelegate = self }
    }

}

// MARK: - HRT2DGameInputSourceGameDelegate conformance

extension HRT2DScene: HRT2DGameInputSourceGameDelegate {

    open func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didPickDirection direction: HRT2DGameInputDirection
    ) {}

    open func inputSourceDidSelect(_ inputSource: HRT2DGameInputSource) {}

    open func inputSourceDidTogglePause(_ inputSource: HRT2DGameInputSource) {}

    #if DEBUG

    open func inputSourceDidToggleDebugInfo(_ inputSource: HRT2DGameInputSource) {}

    open func inputSourceDidTriggerWin(_ inputSource: HRT2DGameInputSource) {}

    open func inputSourceDidTriggerLoss(_ inputSource: HRT2DGameInputSource) {}

    #endif

}
