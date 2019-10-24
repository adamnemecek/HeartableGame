// Copyright © 2019 Heartable LLC. All rights reserved.

import simd
import Foundation

public protocol HRT2DGameInputSourceUnitDelegate: AnyObject {

    /// Indicates the source has updated displacement in cartesian coordinates.
    ///
    /// - Parameter inputSource: The input.
    /// - Parameter displacement: The displacement denoted in (x, y) form.
    func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didUpdateDisplacement displacement: simd_float2
    )

    /// Indicates the source has updated angular displacement in radians.
    ///
    /// - Parameter inputSource: The source.
    /// - Parameter displacement: The displacement denoted as (angle, magnitude).
    func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didUpdateAngularDisplacement displacement: simd_float2
    )

    /// Indicates the source has updated relative displacement, in one of four directions:
    ///   up: (0, 1), down: (0, -1), left: (-1, 0), right: (1, 0)
    ///
    /// - Parameter inputSource: The source.
    /// - Parameter displacement: The relative displacement.
    func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didUpdateRelativeDisplacement displacement: simd_float2
    )

    /// Indicates the source has updated relative angular displacement, in one of two directions:
    ///   clockwise: (-1, 0), counter-clockwise: (1, 0)
    ///
    /// - Parameter inputSource: The source.
    /// - Parameter displacement: The relative angular displacement.
    func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didUpdateRelativeAngularDisplacement displacement: simd_float2
    )

}
