// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

/// A 2D scene overlay.
open class HRT2DOverlay {

    // MARK: - Constants

    open class var overlayNodeName: String { "overlayNode" }

    // MARK: - Props

    /// The overlay's background, which is sized to fill the view.
    private let rootNode: HRT2DViewGuide

    /// The overlay's content.
    private let contentNode: SKSpriteNode

    // MARK: - Config

    /// Work to be done on `rootNode` before entering.
    open var preEntrance: ((SKNode) -> Void)?

    /// Work to be done on `rootNode` after exiting.
    open var postExit: ((SKNode) -> Void)?

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
    /// - Parameter fileName: The name of the file containing the overlay's scene.
    /// - Parameter overlayName: The name of the overlay node.
    public init?(fileNamed fileName: String, overlayNamed overlayName: String? = nil) {
        let overlayName = overlayName ?? Self.overlayNodeName
        guard let overlayScene = SKScene(fileNamed: fileName),
            let overlayNode = overlayScene.childNode(withName: overlayName) as? SKSpriteNode
        else { return nil }

        // Extract the background from the overlay's content so it can be scaled separately from the
        // content.
        rootNode = HRT2DViewGuide(color: overlayNode.color, size: overlayNode.size)

        #if !os(macOS)
        rootNode.insetsToSafeArea = false
        #endif

        // Move the content to the new background node.
        contentNode = overlayNode
        contentNode.removeFromParent()
        contentNode.position = .zero
        contentNode.color = .clear
        rootNode.addChild(contentNode)
    }

    // MARK: - Functionality

    open func attach(
        to parent: SKNode,
        mode: HRTScaleMode = .aspectFit,
        zPosition: CGFloat = .zero,
        _ completion: HRTBlock? = nil
    ) {
        rootNode.removeFromParent()
        preEntrance?(rootNode)

        rootNode.zPosition = zPosition
        parent.addChild(rootNode)
        rescale(mode)

        runEntranceActionIfNeeded() { completion?() }
    }

    open func detach(_ completion: HRTBlock? = nil) {
        runExitActionIfNeeded() {
            self.rootNode.removeFromParent()
            self.postExit?(self.rootNode)
            completion?()
        }
    }

    open func rescale(_ mode: HRTScaleMode = .aspectFit) {
        guard let scene = rootNode.scene,
            let view = scene.view
        else { return }

        let scaleFactors = nativeSize.scaleFactors(to: view.size(in: scene), mode: mode)
        contentNode.xScale = scaleFactors.width
        contentNode.yScale = scaleFactors.height

        rootNode.layout()
    }

    // MARK: - Utils

    private func runEntranceActionIfNeeded(_ completion: HRTBlock? = nil) {
        guard let entranceAction = entranceAction else {
            completion?()
            return
        }
        rootNode.run(entranceAction) { completion?() }
    }

    private func runExitActionIfNeeded(_ completion: HRTBlock? = nil) {
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
    open var nativeSize: CGSize { contentNode.calculateAccumulatedFrame().size }

}
