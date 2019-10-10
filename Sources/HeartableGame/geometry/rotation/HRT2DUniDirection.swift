// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics

public enum HRT2DUniDirection: Int, HRT2DDirection {

    case `default` = 0

    // MARK: - Props

    public var zRotation: CGFloat { return 0 }

    public init(zRotation: CGFloat) {
        self = .default
    }

}
