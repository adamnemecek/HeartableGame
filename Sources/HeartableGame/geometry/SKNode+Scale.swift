// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public extension SKNode {

    func accumulatedScale(_ axis: HRTAxis, through ancestor: SKNode? = nil) -> CGFloat? {
        let path = pathToRoot()
        if let ancestor = ancestor {
            if let ancestorIndex = path.firstIndex(of: ancestor) {
                return accumulatedScale(axis, nodes: Array(path[...ancestorIndex]))
            } else {
                return nil
            }
        } else {
            return accumulatedScale(axis, nodes: path)
        }
    }

    func accumulatedXScale(through ancestor: SKNode? = nil) -> CGFloat? {
        accumulatedScale(.x, through: ancestor)
    }

    func accumulatedYScale(through ancestor: SKNode? = nil) -> CGFloat? {
        accumulatedScale(.y, through: ancestor)
    }

    // MARK: - Utils

    private func accumulatedScale(_ axis: HRTAxis, nodes: [SKNode]) -> CGFloat {
        nodes.reduce(1) { result, node in
            switch axis {
            case .x: return result * node.xScale
            case .y: return result * node.yScale
            }
        }
    }

}
