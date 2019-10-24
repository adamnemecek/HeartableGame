// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics
import Foundation

public protocol HRT2DLayerKey: HRT2DNodeKey {

    static var `default`: Self { get }

    var zPosition: CGFloat { get }

}

public extension HRT2DLayerKey where Self: RawRepresentable, Self.RawValue == CGFloat {

    var zPosition: CGFloat { self.rawValue }

}
