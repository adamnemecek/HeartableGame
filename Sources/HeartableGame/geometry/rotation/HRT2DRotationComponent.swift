// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

@available(iOS 10.0, macOS 10.11, *)
open class HRT2DRotationComponent<Direction>: HRTGameComponent where Direction: HRT2DDirection {

    // MARK: - Props

    open var zRotation: CGFloat = 0.0 {
        didSet {
            zRotation = zRotation.truncatingRemainder(dividingBy: .twoPi)
            direction = Direction(zRotation: zRotation)
        }
    }

    open private(set) lazy var direction = Direction(zRotation: zRotation)

}
