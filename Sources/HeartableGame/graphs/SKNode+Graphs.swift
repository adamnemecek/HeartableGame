// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public extension SKNode {

    func pathToRoot() -> [SKNode] {
        var path = [self]
        var possibleAncestor = parent
        while let ancestor = possibleAncestor {
            path.append(ancestor)
            possibleAncestor = ancestor.parent
        }
        return path
    }

    static func lowestCommonAncestor(lhs: SKNode, rhs: SKNode) -> SKNode? {
        let pathToLHS = Array(lhs.pathToRoot().reversed())
        let pathToRHS = Array(rhs.pathToRoot().reversed())

        var i = 0
        while i < pathToLHS.count && i < pathToRHS.count {
            if pathToLHS[i] !== pathToRHS[i] {
                break
            }
            i += 1
        }
        if i - 1 < 0 { return nil }
        return pathToLHS[i - 1]
    }

}
