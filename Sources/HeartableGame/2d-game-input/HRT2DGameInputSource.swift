// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

/// Source of control input.
public protocol HRT2DGameInputSource: AnyObject {

    var gameDelegate: HRT2DGameInputSourceGameDelegate? { get set }

    var unitDelegate: HRT2DGameInputSourceUnitDelegate? { get set }

    /// Resets the control state.
    func reset()

}

public extension HRT2DGameInputSource {

    func reset() {}

}
