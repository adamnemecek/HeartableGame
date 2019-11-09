// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Heartable
@testable import HeartableGame
import SpriteKit
import XCTest

final class HRT2DRenderingTests: XCTestCase {

    // MARK: - Prep

    // MARK: Scenes

    class SceneA: HRT2DScene, HRTTypeSized, HRTSelfMaking, HRT2DRendering {
        enum LayerKey: CGFloat, HRT2DLayerKey {
            case one = -100, two = -75, three = 25, four = 125
            static var `default` = Self.three

            class EntityBLink: HRT2DFacetLayerLink {
                static func layerKey(for facet: EntityB.Facet) -> SceneA.LayerKey {
                    switch facet {
                    case .uno: return .one
                    case .dos: return .two
                    case .tres: return .three
                    }
                }
            }
        }

        static let typeSize = CGSize(width: 1024, height: 1366)

        @HRTLate var layers: HRTMap<LayerKey, SKNode>
    }

    class SceneB: HRT2DScene, HRTTypeSized, HRTSelfMaking, HRT2DRendering {
        enum LayerKey: CGFloat, HRT2DLayerKey {
            static var `default` = Self.a

            case a = 0

            case b
            case c, d

            case e
            case f
            case g, h

            var parent: Self? {
                switch self {
                case .a: return nil

                case .b: return .a
                case .c: return .b
                case .d: return .b

                case .e: return .a
                case .f: return .e
                case .g: return .f
                case .h: return .f
                }
            }
        }

        static let typeSize = CGSize(width: 1024, height: 1366)

        @HRTLate var layers: HRTMap<LayerKey, SKNode>
    }

    // MARK: Entities

    class EntityA: HRTGameEntity {
        override init() {
            super.init()
            addComponent(ComponentA())
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class EntityB: HRTGameEntity, HRT2DRenderable {
        var componentInfo = ComponentInfo()

        enum Facet: String, HRT2DFacet {
            case uno, dos, tres
            static var `default` = Self.dos
        }

        override init() {
            super.init()
            addNodedComponent(ComponentB())
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class EntityC: HRTGameEntity {}

    // MARK: Components

    class ComponentA: HRTGameComponent {}

    class ComponentB: HRTGameComponent, HRT2DNoded {
        var node = SKNode()
        var nodes: Set<SKNode> { return Set<SKNode>([node]) }
    }

    class ComponentC: HRTGameComponent {}

    class ComponentD: HRTGameComponent, HRT2DNoded {
        var node = SKNode()
        var nodes: Set<SKNode> { return Set<SKNode>([node]) }
    }

    // MARK: Props

    @HRTLate var scene1: SceneA
    @HRTLate var scene2: SceneB

    // MARK: Lifecycle

    override func setUp() {
        scene1 = SceneA.make()
        scene1.loadLayers()
        scene1.componentSystems = [
            ObjectIdentifier(ComponentA.self): GKComponentSystem(componentClass: ComponentA.self),
            ObjectIdentifier(ComponentB.self): GKComponentSystem(componentClass: ComponentB.self),
            ObjectIdentifier(ComponentC.self): GKComponentSystem(componentClass: ComponentC.self),
            ObjectIdentifier(ComponentD.self): GKComponentSystem(componentClass: ComponentD.self)
        ]

        scene2 = SceneB.make()
        scene2.loadLayers()
    }

    // MARK: - Tests

    func testSceneCreation() {
        SceneA.LayerKey.allCases.forEach {
            let layer = scene1.childNode(withName: $0.name)
            XCTAssertNotNil(layer)
            XCTAssert(layer?.name == $0.name)
        }
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }
        XCTAssert(scene1.entities.isEmpty)
    }

    func testLayerNodes() {
        let aPath = SceneB.LayerKey.a.path
        XCTAssertEqual(aPath, "a")
        let aChild = scene2.childNode(withName: aPath)
        XCTAssertEqual(aChild, scene2.layers[.a])
        XCTAssertEqual(aChild?.zPosition, SceneB.LayerKey.a.zPosition)

        let bPath = SceneB.LayerKey.b.path
        XCTAssertEqual(bPath, "a/b")
        let bChild = scene2.childNode(withName: bPath)
        XCTAssertEqual(bChild, scene2.layers[.b])
        XCTAssertEqual(bChild?.zPosition, SceneB.LayerKey.b.zPosition)

        let cPath = SceneB.LayerKey.c.path
        XCTAssertEqual(cPath, "a/b/c")
        let cChild = scene2.childNode(withName: cPath)
        XCTAssertEqual(cChild, scene2.layers[.c])
        XCTAssertEqual(cChild?.zPosition, SceneB.LayerKey.c.zPosition)

        let hPath = SceneB.LayerKey.h.path
        XCTAssertEqual(hPath, "a/e/f/h")
        let hChild = scene2.childNode(withName: hPath)
        XCTAssertEqual(hChild, scene2.layers[.h])
        XCTAssertEqual(hChild?.zPosition, SceneB.LayerKey.h.zPosition)
    }

    // MARK: Entity

    func testNonRenderableEntity() throws {
        // Create entity
        let entity1 = EntityA()
        #if !os(macOS)
        let component1 = try XCTUnwrap(entity1.components.first as? ComponentA)
        #else
        let component1 = entity1.components.first as! ComponentA
        #endif
        XCTAssert(entity1.component(ofType: ComponentA.self) === entity1.components.first)

        // Add entity
        scene1.addEntity(entity1)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }
        XCTAssert(scene1.entities.count == 1)
        XCTAssert(scene1.componentSystem(ComponentA.self)?.components.first === component1)

        // Remove entity
        scene1.removeEntity(entity1)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }
        XCTAssert(scene1.entities.isEmpty)
    }

    func testRenderableEntity() throws {
        // Create entity
        let entity1 = EntityB()
        #if !os(macOS)
        let component1 = try XCTUnwrap(entity1.components.first as? ComponentB)
        #else
        let component1 = entity1.components.first as! ComponentB
        #endif
        XCTAssertNotNil(component1.node)
        let info = try XCTUnwrap(entity1.componentInfo[ObjectIdentifier(ComponentB.self)])
        XCTAssert(info.facet == .dos)
        XCTAssert(info.component === component1)

        // Add entity
        scene1.addEntity(entity1)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }
        XCTAssert(scene1.entities.count == 1)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.first === component1)

        // Render entity
        scene1.render(entity1, link: SceneA.LayerKey.EntityBLink.self)
        XCTAssert(scene1.layers[.one].children.isEmpty)
        XCTAssert(scene1.layers[.two].children.first === component1.node)
        XCTAssert(scene1.layers[.three].children.isEmpty)
        XCTAssert(scene1.layers[.four].children.isEmpty)

        // Remove entity
        scene1.removeEntity(entity1)
        XCTAssert(scene1.entities.isEmpty)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.isEmpty == true)
        XCTAssert(scene1.layers[.two].children.first === component1.node)

        // Unrender entity
        scene1.unrender(entity1)
        XCTAssert(scene1.layers[.two].children.isEmpty)

        // Intro entity
        scene1.intro(entity1, link: SceneA.LayerKey.EntityBLink.self)
        XCTAssert(scene1.entities.count == 1)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.first === component1)
        XCTAssert(scene1.layers[.one].children.isEmpty)
        XCTAssert(scene1.layers[.two].children.first === component1.node)
        XCTAssert(scene1.layers[.three].children.isEmpty)
        XCTAssert(scene1.layers[.four].children.isEmpty)

        // Outro entity
        scene1.outro(entity1)
        XCTAssert(scene1.entities.isEmpty)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.isEmpty == true)
        XCTAssert(scene1.layers[.two].children.isEmpty)
    }

    // MARK: Component

    func testNonRenderableEntity_NonNodedComponent() {
        let entity1 = EntityC()
        XCTAssert(entity1.components.isEmpty)
        scene1.addEntity(entity1)

        // Add component to entity directly
        let component1 = ComponentA()
        entity1.addComponent(component1)
        XCTAssert(entity1.components.count == 1)
        XCTAssertNil(scene1.componentSystem(ComponentA.self)?.components.first)

        // Remove component from entity directly
        entity1.removeComponent(ofType: type(of: component1))
        XCTAssert(entity1.components.isEmpty)

        // Add component to entity via scene
        let component2 = ComponentC()
        scene1.addComponent(component2, to: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(scene1.componentSystem(ComponentC.self)?.components.first === component2)

        // Remove component from entity via scene
        scene1.removeComponent(component2, from: entity1)
        XCTAssert(entity1.components.isEmpty)
        XCTAssertNil(scene1.componentSystem(ComponentC.self)?.components.first)
    }

    func testNonRenderableEntity_NodedComponent() {
        let entity1 = EntityC()
        scene1.addEntity(entity1)

        // Add component to entity directly
        let component1 = ComponentB()
        entity1.addComponent(component1)
        XCTAssert(entity1.components.count == 1)
        XCTAssertNil(scene1.componentSystem(ComponentB.self)?.components.first)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }

        // Remove component from entity directly
        entity1.removeComponent(ofType: type(of: component1))
        XCTAssert(entity1.components.isEmpty)

        // Add component to entity via scene
        let component2 = ComponentD()
        scene1.addComponent(component2, to: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(scene1.componentSystem(ComponentD.self)?.components.first === component2)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }

        // Remove component from entity via scene
        scene1.removeComponent(component2, from: entity1)
        XCTAssert(entity1.components.isEmpty)
        XCTAssertNil(scene1.componentSystem(ComponentD.self)?.components.first)
    }

    func testRenderableEntity_NonNodedComponent() {
        let entity1 = EntityB()
        scene1.addEntity(entity1)

        // Add component to entity directly
        let component1 = ComponentA()
        entity1.addComponent(component1)
        XCTAssert(entity1.components.count == 2)
        XCTAssertNil(scene1.componentSystem(ComponentA.self)?.components.first)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }

        // Remove component from entity directly
        entity1.removeComponent(ofType: ComponentA.self)
        XCTAssert(entity1.components.count == 1)

        // Add component to entity via scene
        scene1.addComponent(component1, to: entity1)
        XCTAssert(entity1.components.count == 2)
        XCTAssert(scene1.componentSystem(ComponentA.self)?.components.first === component1)
        scene1.layers.values.forEach { XCTAssert($0.children.isEmpty) }

        // Remove component from entity via scene
        scene1.removeComponent(component1, from: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssertNil(scene1.componentSystem(ComponentA.self)?.components.first)
    }

    func testRenderableEntity_NodedComponent() throws {
        let entity1 = EntityB()
        scene1.intro(entity1, link: SceneA.LayerKey.EntityBLink.self)
        #if !os(macOS)
        let component0 = try XCTUnwrap(scene1.componentSystem(ComponentB.self)?.components.first)
        #else
        let component0 = scene1.componentSystem(ComponentB.self)!.components.first!
        #endif

        // Add same component type to entity directly
        let component1 = ComponentB()
        entity1.addComponent(component1)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.first === component0)

        // Add different component type to entity directly
        let component2 = ComponentD()
        entity1.addComponent(component2)
        XCTAssert(entity1.components.count == 2)
        XCTAssertNil(scene1.componentSystem(ComponentD.self)?.components.first)
        XCTAssert(scene1.layers[.two].children.count == 1)

        // Remove component from entity directly
        entity1.removeComponent(ofType: ComponentD.self)
        XCTAssert(entity1.components.count == 1)

        // Add same component type to entity via scene
        scene1.addComponent(component1, to: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.count == 2)

        // Add different component type to entity via scene
        scene1.addComponent(component2, to: entity1)
        XCTAssert(entity1.components.count == 2)
        XCTAssertNotNil(scene1.componentSystem(ComponentD.self)?.components.first)
        XCTAssert(scene1.layers[.two].children.count == 1)

        // Remove component from entity via scene
        scene1.removeComponent(component2, from: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssertNil(scene1.componentSystem(ComponentD.self)?.components.first)

        // Intro same component type to entity via scene
        scene1.intro(component1, to: entity1, link: SceneA.LayerKey.EntityBLink.self)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.count == 2)
        XCTAssert(scene1.layers[.two].children.count == 2)

        // Outro same component type from entity via scene
        scene1.outro(component1, from: entity1)
        XCTAssert(entity1.components.isEmpty)
        XCTAssert(scene1.componentSystem(ComponentB.self)?.components.count == 1)
        XCTAssert(scene1.layers[.two].children.count == 1)
    }

    // MARK: Facet

    func testFacet() throws {
        let link = SceneA.LayerKey.EntityBLink.self
        let entity1 = EntityB()
        scene1.intro(entity1, link: link)
        #if !os(macOS)
        let component1 = try XCTUnwrap(entity1.components.first as? ComponentB)
        #else
        let component1 = entity1.components.first as! ComponentB
        #endif
        XCTAssert(scene1.layers[.two].children.first === component1.node)

        // Add same-type component to a different facet
        let component2 = ComponentB()
        scene1.intro(component2, to: entity1, facet: .uno, link: link)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(entity1.nodes.count == 1)
        XCTAssert(scene1.layers[.two].children.isEmpty)
        XCTAssert(scene1.layers[.one].children.first === component2.node)

        // Add different-type component to same facet
        let component3 = ComponentD()
        scene1.intro(component3, to: entity1, facet: .uno, link: link)
        XCTAssert(entity1.components.count == 2)
        XCTAssert(entity1.nodes.count == 2)
        XCTAssert(scene1.layers[.one].children.count == 2)
        XCTAssert(scene1.layers[.one].children.contains(component2.node))
        XCTAssert(scene1.layers[.one].children.contains(component3.node))

        // Remove component
        scene1.outro(component2, from: entity1)
        XCTAssert(entity1.components.count == 1)
        XCTAssert(entity1.nodes.count == 1)
        XCTAssert(scene1.layers[.one].children.count == 1)
        XCTAssert(scene1.layers[.one].children.first === component3.node)

        // Add entity with added components
        let entity2 = EntityB()
        #if !os(macOS)
        let component4 = try XCTUnwrap(entity2.components.first as? ComponentB)
        #else
        let component4 = entity2.components.first as! ComponentB
        #endif
        let component5 = ComponentA()
        entity2.addComponent(component5)
        let component6 = ComponentD()
        entity2.addNodedComponent(component6, facet: .tres)
        scene1.intro(entity2, link: link)
        XCTAssert(scene1.layers[.one].children.first === component3.node)
        XCTAssert(scene1.layers[.two].children.first === component4.node)
        XCTAssert(scene1.layers[.three].children.first === component6.node)

        // Remove entity
        scene1.outro(entity2)
        XCTAssert(scene1.layers[.one].children.first === component3.node)
        XCTAssert(scene1.layers[.two].children.isEmpty)
        XCTAssert(scene1.layers[.three].children.isEmpty)
    }

}
