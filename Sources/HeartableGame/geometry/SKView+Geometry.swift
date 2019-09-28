// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

// MARK: - Geometry

public extension SKView {

    // MARK: Scaling

    /// Returns the size of this view in scene-scale, i.e. the size at which a scene's node appears
    /// to match the view's size, given the view-to-scene size ratio and scale mode.
    ///
    /// - Parameter scene: The scene.
    /// - Returns: The scaled size.
    func size(in scene: SKScene) -> CGSize {
        let factors = scaleFactors(to: scene)
        return CGSize(
            width: bounds.size.width * factors.width,
            height: bounds.size.height * factors.height
        )
    }

    /// Returns multipliers for scaling from view-scale to scene-scale.
    ///
    /// - Parameter scene: The scene.
    /// - Returns: A tuple of scaling factors.
    func scaleFactors(to scene: SKScene) -> (width: CGFloat, height: CGFloat) {
        switch scene.scaleMode {
        case .fill: return bounds.size.scaleFactors(to: scene.size, mode: .fill)
        case .aspectFill: return bounds.size.scaleFactors(to: scene.size, mode: .aspectFit)
        case .aspectFit: return bounds.size.scaleFactors(to: scene.size, mode: .aspectFill)
        case .resizeFill: return (width: 1, height: 1)
        @unknown default: return (width: 1, height: 1)
        }
    }

}
