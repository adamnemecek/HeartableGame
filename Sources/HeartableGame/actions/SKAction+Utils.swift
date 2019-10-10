// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public extension SKAction {

    /// Creates a repeating action wrapping the receiver.
    ///
    /// - Parameter count: The number of times to repeat. If 0, repeats forever.
    func repeated(_ count: Int) -> SKAction {
        return count <= 0
            ? SKAction.repeatForever(self)
            : SKAction.repeat(self, count: count)
    }

}
