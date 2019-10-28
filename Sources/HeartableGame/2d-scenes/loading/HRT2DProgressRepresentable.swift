// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

public protocol HRT2DProgressRepresentable: SKNode {

    var progressAction: SKAction? { get }

    func resetProgress()
    
    func updateProgress(_ fractionCompleted: Double, animated: Bool, completion: HRTBlock?)

}
