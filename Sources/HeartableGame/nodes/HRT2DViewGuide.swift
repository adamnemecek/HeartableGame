// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

@available(iOS 10.0, *)
/// A node that is always positioned in the center of its parent, with the same size as its view
/// scaled to aspect-fit its scene.
open class HRT2DViewGuide: SKSpriteNode {

    // MARK: - Props

    // MARK: Settings

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

    // MARK: - Layout

    public func layout() {
        guard let parent = parent,
            let scene = scene,
            let view = scene.view
        else { return }

        // Find the view size in scene-scale.
        let size = view.size(in: scene)
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let center = CGPoint(x: parent.frame.width / 2, y: parent.frame.height / 2)
        let minPoint = CGPoint(x: center.x - halfWidth, y: center.y - halfHeight)
        var scaledRect = CGRect(origin: minPoint, size: size)

        #if !os(macOS)

        // Adjust for safe area.
        if #available(iOS 11, *),
            insetsToSafeArea
        {
            scaledRect = scaledRect.inset(by: view.safeAreaInsets)
        }

        #endif

        // Adjust for margins.
        scaledRect = scaledRect.inset(by: margins)

        _frame = scaledRect
    }

}
