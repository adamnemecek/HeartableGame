// Copyright © 2019 Heartable LLC. All rights reserved.

import simd
import Foundation

public enum HRT2DGameInputDirection {

    case up, down, left, right

    // MARK: - Creational

    public static func make(_ vector: simd_float2) -> Self? {
        return Self.init(vector, minDisplacement: 0.5)
    }

    // MARK: - Init

    public init?(_ vector: simd_float2, minDisplacement: Float) {
        guard length(vector) >= minDisplacement else { return nil }

        // Determine the axis.
        if abs(vector.x) > abs(vector.y) {
            self = vector.x > 0 ? .right : .left
        } else {
            self = vector.y > 0 ? .up : .down
        }
    }

}
