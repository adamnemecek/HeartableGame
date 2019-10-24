// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

/// A node that is always positioned in the center of its parent, with the same size as its view
/// scaled to aspect-fit its scene (so that the scene aspect-fills the view).
open class HRT2DViewGuide: SKSpriteNode {

    // MARK: - Props

    // MARK: Config

    /// Custom insets. Safe-area-sensitive.
    public var margins: HRTInsets = .zero {
        didSet { layout() }
    }

    #if !os(macOS)

    /// If true, insets to safe area.
    public var insetsToSafeArea = true {
        didSet { layout() }
    }

    #endif

    // MARK: Geometry

    override public var frame: CGRect {
        return _frame
    }

    private var _frame: CGRect = .zero

}

// MARK: - HRTLayoutCapable conformance

extension HRT2DViewGuide: HRTLayoutCapable {

    public func layout() {
        guard let parent = parent,
            let scene = scene,
            let view = scene.view
        else { return }

        // Find the view size in scene-scale.
        let viewSize = view.size(in: scene)
        let halfWidth = viewSize.width / 2
        let halfHeight = viewSize.height / 2
        let center = CGPoint(x: parent.frame.width / 2, y: parent.frame.height / 2)
        let minPoint = CGPoint(x: center.x - halfWidth, y: center.y - halfHeight)
        var scaledRect = CGRect(origin: minPoint, size: viewSize)

        #if !os(macOS)

        // Adjust for safe area.
        if insetsToSafeArea {
            scaledRect = scaledRect.inset(by: view.safeAreaInsets)
        }

        #endif

        // Adjust for margins.
        scaledRect = scaledRect.inset(by: margins)

        size = scaledRect.size
        _frame = scaledRect
    }

}
