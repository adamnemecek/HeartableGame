// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import SpriteKit

public protocol HRT2DProgressRepresentable: SKNode {

    func updateProgress(_ fractionCompleted: Double)

}
