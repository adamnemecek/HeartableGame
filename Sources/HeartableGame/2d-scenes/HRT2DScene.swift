// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreHaptics
import GameplayKit
import Heartable
import SpriteKit

open class HRT2DScene: SKScene, HRTEponymous, HRTGameplayBased, HRT2DAssetsLoading {

    // MARK: - Config

    // MARK: - Type props

    // MARK: Assets
    open class var textureNames: [String] { [] }
    open class var textureAtlasNames: [String] { [] }

    // MARK: Loading
    open class var shouldLoadAssets: Bool { true }
    open class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }

    // MARK: - Type functionality

    // MARK: Loading

    open class func loadAssets(completion: @escaping HRTBlock) {
        load2DAssets { _, _ in completion() }
    }

    open class func unloadAssets() {}

    // MARK: - Props

    open weak var moveDelegate: HRT2DSceneMoveDelegate?

    open weak var stage: HRT2DStage? {
        didSet { stage?.input?.delegate = self }
    }

    open var entities = Set<GKEntity>()
    
    open var componentSystems = [ObjectIdentifier: GKComponentSystem<GKComponent>]()

    open var overlay: HRT2DOverlay? {
        didSet {
            if let camera = camera { overlay?.attach(to: camera, zPosition: 0) }
            oldValue?.detach()
        }
    }

    open var curtain: HRT2DCurtain? {
        didSet {
            if let camera = camera { curtain?.attach(to: camera, zPosition: 1) }
            oldValue?.detach()
        }
    }

    // MARK: Config

    open var isHaptic = false

    // MARK: State

    open lazy var curtainStateMachine = GKStateMachine(states: [
        HRT2DSceneOpening(self),
        HRT2DSceneOpened(self),
        HRT2DSceneClosing(self),
        HRT2DSceneClosed(self)
    ])

    open var exitCompletion: HRTBlock?

    open var lastUpdateTime: TimeInterval = 0

    // MARK: Haptics

    open var hapticEngine: UIImpactFeedbackGenerator?

    // MARK: - Lifecycle

    open override func sceneDidLoad() {
        super.sceneDidLoad()
        scaleMode = .aspectFill
        if camera == nil { setUpCamera() }
    }

    open override func didMove(to view: SKView) {
        super.didMove(to: view)

        rescale()

        curtainStateMachine.enter(HRT2DSceneOpening.self)

        entities
            .compactMap { $0 as? HRTGameEntity }
            .forEach { $0.didMove(to: view) }

        if isHaptic { HRTUIHaptics.setUp() }

        moveDelegate?.sceneDidMove(self)
    }

    open override func willMove(from view: SKView) {
        super.willMove(from: view)

        entities
            .compactMap { $0 as? HRTGameEntity }
            .forEach { $0.willMove(from: view) }

        if isHaptic { HRTUIHaptics.tearDown() }

        moveDelegate?.sceneWillMove(self)
    }

    open override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        rescale()
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
        guard !entities.contains(entity) else { return }
        entities.insert(entity)
        componentSystems.values.forEach { $0.addComponent(foundIn: entity) }
        (entity as? HRTGameEntity)?.didMove(to: self)
    }

    open func removeEntity(_ entity: GKEntity) {
        guard entities.contains(entity) else { return }
        (entity as? HRTGameEntity)?.willMove(from: self)
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
        guard entities.contains(entity) else { return }

        if let currComponent = entity.component(ofType: componentType) {
            removeComponent(currComponent, from: entity)
        }

        entity.addComponent(component)
        componentSystem(componentType)?.addComponent(component)
        (component as? HRTGameComponent)?.didMove(to: self)
    }

    open func removeComponent(_ component: GKComponent, from entity: GKEntity) {
        let componentType = type(of: component)
        guard entities.contains(entity),
            let currComponent = entity.component(ofType: componentType),
            currComponent === component
        else { return }

        (component as? HRTGameComponent)?.willMove(from: self)
        entity.removeComponent(ofType: componentType)
        componentSystem(componentType)?.removeComponent(component)
    }

    // MARK: Setup

    open func setUpCamera() {
        camera?.removeFromParent()
        let camera = SKCameraNode()
        camera.position = .zero
        addChild(camera)
        self.camera = camera
    }

    // MARK: - Utils

    open func rescale() {
        overlay?.rescale()
        curtain?.rescale()
    }

    open func config(_ info: HRT2DSceneInfo) {
        isHaptic = info.isHaptic
    }

    open func prepareToMove(from view: SKView, completion: HRTBlock? = nil) {
        switch curtainStateMachine.currentState {
        case is HRT2DSceneOpening, is HRT2DSceneOpened:
            exitCompletion = completion
            curtainStateMachine.enter(HRT2DSceneClosing.self)
        default: completion?()
        }
    }

}

// MARK: - HRT2DGameInputDelegate conformance

extension HRT2DScene: HRT2DGameInputDelegate {

    open func inputDidUpdateSources(_ input: HRT2DGameInput) {
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
