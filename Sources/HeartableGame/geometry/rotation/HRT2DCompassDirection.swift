// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics

public enum HRT2DCompassDirection: Int, HRT2DDirection {

    case east = 0, eastByNorthEast, northEast, northByNorthEast
    case north, northByNorthWest, northWest, westByNorthWest
    case west, westBySouthWest, southWest, southBySouthWest
    case south, southBySouthEast, southEast, eastBySouthEast

    // MARK: - Props

    public var zRotation: CGFloat {
        let radiansPerDirection = CGFloat.twoPi / CGFloat(Self.allCases.count)
        return CGFloat(self.rawValue) * radiansPerDirection
    }

    // MARK: - Init

    public init(zRotation: CGFloat) {
        // Normalize rotation.
        let rotation = zRotation.truncatingRemainder(dividingBy: .twoPi)

        // Find the orientation as the percentage of a circle.
        let orientation = rotation / .twoPi

        // Convert to a 0...15 scale.
        let value = Int(round(orientation * 16))

        self = Self(rawValue: value)!
    }

}
