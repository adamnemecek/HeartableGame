// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public extension SKNode {

    /// Calculates the position (in `node`'s parent's coordinate space) of the specified anchor
    /// on `guide`.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - guideAnchor: The anchor on `guide`.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position of the specified anchor, or nil if not calculable.
    static func position(
        of node: SKNode,
        guide: SKNode? = nil,
        guideAnchor: HRT2DPositionAnchor,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let nodeParent = node.parent else { return nil }

        let target = guide ?? nodeParent
        let targetParent = target.parent ?? target

        // Find the minimum point (i.e. the bottom-leftmost point) in the target's parent's
        // coordinate space.
        let targetMin = CGPoint(x: target.frame.minX, y: target.frame.minY)

        // Convert the minimum point to `node`'s parent's coordinate space.
        let convertedTargetMin = nodeParent.convert(targetMin, from: targetParent)

        // Find the position of the target anchor.
        let targetAnchorPosition = CGPoint(
            x: convertedTargetMin.x + (target.frame.width * guideAnchor.unitPoint.x),
            y: convertedTargetMin.y + (target.frame.height * guideAnchor.unitPoint.y)
        )

        // Apply offsets and return the final position.
        return targetAnchorPosition + constants
    }

    /// Calculates the position (in `node`'s parent's coordinate space) that, if assigned to node,
    /// would reposition the specified `node` anchor onto the specified `guide` anchor.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - nodeAnchor: The anchor on `node`.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - guideAnchor: The anchor on `guide`.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position as described, or nil if not calculable.
    static func position(
        of node: SKNode,
        withSubtree: Bool = true,
        nodeAnchor: HRT2DPositionAnchor,
        guide: SKNode? = nil,
        guideAnchor: HRT2DPositionAnchor,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let guideAnchorPosition = position(
            of: node,
            guide: guide,
            guideAnchor: guideAnchor,
            constants: constants
        )
        else { return nil }

        let nodeFrame = withSubtree ? node.calculateAccumulatedFrame() : node.frame

        // Find the minimum point of `node` in its parent's coorindate space.
        let nodeMin = CGPoint(x: nodeFrame.minX, y: nodeFrame.minY)

        // Find the position of the specified `node` anchor.
        let nodeAnchorPosition = CGPoint(
            x: nodeMin.x + (nodeFrame.width * nodeAnchor.unitPoint.x),
            y: nodeMin.y + (nodeFrame.height * nodeAnchor.unitPoint.y)
        )

        // Find the offset between the node anchor's position and the guide anchor's position.
        let anchorPositionsOffset = guideAnchorPosition - nodeAnchorPosition

        // With the offset, we no longer need to take `node`'s `anchorPoint` property (if any) into
        // consideration, and can now directly derive and return the final position.
        return node.position + anchorPositionsOffset
    }

    /// Aligns this node to `guide`, based on the specified `nodeAnchor` and `guideAnchor`.
    ///
    /// - Parameters:
    ///     - nodeAnchor: The anchor on `node` to align with. If nil, uses the inherent `anchorPoint`, if any.
    ///     - withSubtree: True if `node`'s frame is accumulated.
    ///     - guideAnchor: The anchor on `guide` to align to.
    ///     - guide: The target node. If nil, defaults to this node's parent.
    ///     - constants: Offsets to apply to the position.
    func align(
        _ nodeAnchor: HRT2DPositionAnchor? = nil,
        collectively withSubtree: Bool = true,
        to guideAnchor: HRT2DPositionAnchor,
        of guide: SKNode? = nil,
        constants: CGPoint = .zero
    ) {
        let position: CGPoint?
        if let nodeAnchor = nodeAnchor {
            position = SKNode.position(
                of: self,
                withSubtree: withSubtree,
                nodeAnchor: nodeAnchor,
                guide: guide,
                guideAnchor: guideAnchor,
                constants: constants
            )
        } else {
            position = SKNode.position(
                of: self,
                guide: guide,
                guideAnchor: guideAnchor,
                constants: constants
            )
        }
        if let position = position {
            self.position = position
        }
    }

}
