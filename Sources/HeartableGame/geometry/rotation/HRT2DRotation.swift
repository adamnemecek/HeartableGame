// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics

public protocol HRT2DDirection: CaseIterable, Hashable {

    var zRotation: CGFloat { get }

    init(zRotation: CGFloat)

}
