// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public extension SKNode {

    /// Returns a rect representing the view's size in scene-scale, center-positioned in the node's
    /// parent's frame (thus not necessarily positioned at (0, 0)).
    ///
    /// - Parameters:
    ///   - mode: The view guide's mode.
    ///   - margins: Margins, if any.
    /// - Returns: The rect as described, in the node's parent's coordinate space.
    func viewGuide(_ mode: HRT2DViewGuideMode = .full, margins: HRTInsets = .zero) -> CGRect? {
        guard let parent = parent,
            let scene = scene,
            let view = scene.view
        else { return nil }

        // Find the view size in scene-scale.
        let viewSize = view.size(in: scene)
        let halfWidth = viewSize.width / 2
        let halfHeight = viewSize.height / 2
        let center = parent.frame.center
        let minPoint = CGPoint(x: center.x - halfWidth, y: center.y - halfHeight)
        var scaledRect = CGRect(origin: minPoint, size: viewSize)

        #if !os(macOS)
        // Adjust for safe area.
        if mode == .safeAreaLimited {
            scaledRect = scaledRect.inset(by: view.safeAreaInsets)
        }
        #endif

        // Adjust for margins.
        scaledRect = scaledRect.inset(by: margins, coordinateSystem: .cartesian)

        return scaledRect
    }

}
