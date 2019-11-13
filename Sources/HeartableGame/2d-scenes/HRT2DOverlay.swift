// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

/// A 2D scene overlay.
open class HRT2DOverlay {

    // MARK: - Constants

    open class var overlayNodeName: String { "overlayNode" }

    #if !os(macOS)
    open class var safeAreaNodeName: String { "safeAreaNode" }
    #endif

    // MARK: - Props

    /// The overlay's background, which is sized to fill the view.
    let rootNode: HRT2DViewGuide

    #if !os(macOS)
    let safeAreaNode: HRT2DViewGuide
    #endif

    /// The overlay's content.
    let contentNode: SKNode

    /// The handler that lays out the content node, given the root node.
    var layoutContent: HRT2DNodeBlock?

    /// The scale mode of the overlay's content.
    var scaleMode: HRTScaleMode?

    // MARK: - Config

    /// Action run by `rootNode` upon entrance.
    open var entranceAction: SKAction?

    /// Action run by `rootNode` upon exit.
    open var exitAction: SKAction?

    #if !os(macOS)
    /// If true, insets background to safe area.
    open var insetsToSafeArea: Bool {
        get { rootNode.insetsToSafeArea }
        set { rootNode.insetsToSafeArea = newValue }
    }
    #endif

    // MARK: - Init

    /// Initializes a scene overlay.
    ///
    /// - Important: The scene must contain a child sprite node with the specified name.
    ///
    /// - Parameters:
    ///     - fileName: The name of the file containing the overlay's scene.
    ///     - overlayName: The name of the overlay node.
    ///     - layoutContent: The handler that lays out the content node, given the root node.
    ///     - scaleMode: The scale mode to use for the overlay node.
    public init?(
        fileNamed fileName: String,
        overlayNamed overlayName: String? = nil,
        layoutContent: HRT2DNodeBlock? = nil,
        scaleMode: HRTScaleMode? = nil
    ) {
        let overlayName = overlayName ?? Self.overlayNodeName
        guard let overlayScene = SKScene(fileNamed: fileName),
            let overlayNode = overlayScene.childNode(withName: overlayName) as? SKSpriteNode
        else { return nil }

        self.layoutContent = layoutContent
        self.scaleMode = scaleMode

        // Extract the background from the overlay's content so it can be scaled separately from the
        // content.
        rootNode = HRT2DViewGuide(color: overlayNode.color, size: .zero)

        #if !os(macOS)
        rootNode.insetsToSafeArea = false

        safeAreaNode = HRT2DViewGuide()
        safeAreaNode.insetsToSafeArea = true
        #endif

        // Move the content to the new background node.
        overlayNode.position = .zero
        overlayNode.color = .clear
        contentNode = overlayNode
        contentNode.removeFromParent()
        rootNode.addChild(contentNode)
    }

    #if !os(macOS)

    public init(
        _ contentNode: SKNode,
        color: UIColor = .clear,
        layoutContent: HRT2DNodeBlock? = nil,
        scaleMode: HRTScaleMode? = nil
    ) {
        self.contentNode = contentNode
        self.layoutContent = layoutContent
        self.scaleMode = scaleMode

        rootNode = HRT2DViewGuide(color: color, size: .zero)
        rootNode.insetsToSafeArea = false

        safeAreaNode = HRT2DViewGuide()
        safeAreaNode.name = Self.safeAreaNodeName
        safeAreaNode.insetsToSafeArea = true
        safeAreaNode.removeFromParent()
        rootNode.addChild(safeAreaNode)

        self.contentNode.position = .zero
        self.contentNode.removeFromParent()
        rootNode.addChild(self.contentNode)
    }

    #endif

    // MARK: - Functionality

    open func attach(
        to parent: SKCameraNode,
        zPosition: CGFloat? = nil,
        _ completion: HRTBlock? = nil
    ) {
        rootNode.zPosition = zPosition ?? parent.zPosition
        rootNode.removeFromParent()
        parent.addChild(rootNode)
        rescale()

        runEntranceActionIfNeeded() { completion?() }
    }

    open func detach(_ completion: HRTBlock? = nil) {
        runExitActionIfNeeded() {
            self.rootNode.removeFromParent()
            completion?()
        }
    }

    open func rescale() {
        guard let scene = rootNode.scene,
            let view = scene.view
        else { return }

        rootNode.layout()
        safeAreaNode.layout()

        if let layoutContent = layoutContent {
            layoutContent(rootNode)
        } else if let scaleMode = scaleMode {
            let scaleFactors = nativeSize.scaleFactors(to: view.size(in: scene), mode: scaleMode)
            contentNode.xScale = scaleFactors.width
            contentNode.yScale = scaleFactors.height
        }
    }

    // MARK: - Utils

    func runEntranceActionIfNeeded(_ completion: HRTBlock? = nil) {
        guard let entranceAction = entranceAction else {
            completion?()
            return
        }
        rootNode.run(entranceAction) { completion?() }
    }

    func runExitActionIfNeeded(_ completion: HRTBlock? = nil) {
        guard let exitAction = exitAction else {
            completion?()
            return
        }
        rootNode.run(exitAction) { completion?() }
    }

}

// MARK: - HRTNativelySized conformance

extension HRT2DOverlay: HRTNativelySized {

    /// The original content size.
    open var nativeSize: CGSize { contentNode.frame(.accumulated).size }

}
