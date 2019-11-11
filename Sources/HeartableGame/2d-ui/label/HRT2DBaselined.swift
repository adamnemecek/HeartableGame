// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import SpriteKit

public protocol HRT2DBaselined: SKNode {

    /// The unit point of the baseline.
    func baselineUnitPoint(frameMode: HRT2DFrameMode) -> CGPoint

}
