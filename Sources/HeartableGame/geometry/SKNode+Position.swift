// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public extension SKNode {

    /// Calculates the position (in `node`'s parent's coordinate space) of `point` (which is in
    /// `guide`'s coordinate space.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - point: The target point in `guide`'s coordinate space.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position of `point` in `node`'s parent's coordinate space.
    static func position(
        for node: SKNode,
        matching point: CGPoint,
        in guide: SKNode? = nil,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let nodeParent = node.parent else { return nil }
        let target = guide ?? nodeParent
        let convertedPoint = nodeParent.convert(point, from: target)
        return convertedPoint + constants
    }

    /// Calculates the position (in `node`'s parent's coordinate space) of the specified anchor
    /// on `guide`.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - guideAnchor: The anchor on `guide`. If nil, defaults to `guide`'s position.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - withGuideSubtree: True iff `guide`'s frame is accumulated.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position of the specified anchor in `node`'s parent's coordinate space, or
    ///     nil if not calculable.
    static func position(
        for node: SKNode,
        matching guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        withGuideSubtree: Bool = false,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let nodeParent = node.parent else { return nil }

        let target = guide ?? nodeParent
        let targetParent = target.parent ?? target

        guard let guideAnchor = guideAnchor else {
            // No guide anchor is provided, so simply use the guide's position.
            let convertedTargetPosition = nodeParent.convert(target.position, from: targetParent)
            return convertedTargetPosition + constants
        }

        // Find the minimum point (i.e. the bottom-leftmost point) in the target's parent's
        // coordinate space.
        let targetFrame = withGuideSubtree ? target.calculateAccumulatedFrame() : target.frame
        let targetMin = CGPoint(x: targetFrame.minX, y: targetFrame.minY)

        // Convert the minimum point to `node`'s parent's coordinate space.
        let convertedTargetMin = nodeParent.convert(targetMin, from: targetParent)

        // Find the position of the target anchor.
        let convertedTargetAnchorPosition = CGPoint(
            x: convertedTargetMin.x + (targetFrame.width * guideAnchor.unitPoint.x),
            y: convertedTargetMin.y + (targetFrame.height * guideAnchor.unitPoint.y)
        )

        // Apply offsets and return the final position.
        return convertedTargetAnchorPosition + constants
    }

    /// Calculates the position (in `node`'s parent's coordinate space) that, if assigned to node,
    /// would place the specified `nodeAnchor` onto the specified `point`.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - nodeAnchor: The anchor on `node`.
    ///     - withSubtree: True iff `node`'s frame is accumulated.
    ///     - point: The target point in `guide`'s coordinate space.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position as described, or nil if not calculable.
    static func position(
        for node: SKNode,
        at nodeAnchor: HRT2DPositionAnchor,
        withSubtree: Bool = true,
        matching point: CGPoint,
        in guide: SKNode? = nil,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let pointPosition = position(
            for: node,
            matching: point,
            in: guide,
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

        // Find the offset between the node anchor's position and the point's position.
        let anchorPositionsOffset = pointPosition - nodeAnchorPosition

        // With the offset, we no longer need to take `node`'s `anchorPoint` property (if any) into
        // consideration, and can now directly derive and return the final position.
        return node.position + anchorPositionsOffset
    }

    /// Calculates the position (in `node`'s parent's coordinate space) that, if assigned to node,
    /// would place the specified `node` anchor onto the specified `guide` anchor.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - nodeAnchor: The anchor on `node`.
    ///     - withSubtree: True iff `node`'s frame is accumulated.
    ///     - guideAnchor: The anchor on `guide`. If nil, defaults to `guide`'s position.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - withGuideSubtree: True iff `guide`'s frame is accumulated.
    ///     - constants: Offsets to apply to the position.
    /// - Returns: The position as described, or nil if not calculable.
    static func position(
        for node: SKNode,
        at nodeAnchor: HRT2DPositionAnchor,
        withSubtree: Bool = true,
        matching guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        withGuideSubtree: Bool = false,
        constants: CGPoint = .zero
    ) -> CGPoint? {
        guard let guideAnchorPosition = position(
            for: node,
            matching: guideAnchor,
            of: guide,
            withGuideSubtree: withGuideSubtree,
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

    /// Aligns this node to `guide`, based on the specified `nodeAnchor` and `point`.
    ///
    /// - Parameters:
    ///     - nodeAnchor: The anchor on `node` to align with. If nil, uses `SKNode`'s inherent
    ///       `anchorPoint`.
    ///     - withSubtree: True iff `node`'s frame is accumulated.
    ///     - point: The target point in `guide`'s coordinate space.
    ///     - guide: The target node. If nil, defaults to this node's parent.
    ///     - withGuideSubtree: True iff `guide`'s frame is accumulated.
    ///     - constants: Offsets to apply to the position.
    func align(
        _ nodeAnchor: HRT2DPositionAnchor? = nil,
        withSubtree: Bool = true,
        to point: CGPoint,
        in guide: SKNode? = nil,
        withGuideSubtree: Bool = false,
        constants: CGPoint = .zero
    ) {
        let position: CGPoint?

        if let nodeAnchor = nodeAnchor {
            position = SKNode.position(
                for: self,
                at: nodeAnchor,
                withSubtree: withSubtree,
                matching: point,
                in: guide,
                constants: constants
            )
        } else {
            position = SKNode.position(
                for: self,
                matching: point,
                in: guide,
                constants: constants
            )
        }

        if let position = position { self.position = position }
    }

    /// Aligns this node to `guide`, based on the specified `nodeAnchor` and `guideAnchor`.
    ///
    /// - Parameters:
    ///     - nodeAnchor: The anchor on `node` to align with. If nil, uses SKNode's inherent
    ///       `anchorPoint`.
    ///     - withSubtree: True iff `node`'s frame is accumulated.
    ///     - guideAnchor: The anchor on `guide` to align to. If nil, defaults to `guide`'s
    ///         position.
    ///     - guide: The target node. If nil, defaults to this node's parent.
    ///     - withGuideSubtree: True iff `guide`'s frame is accumulated.
    ///     - constants: Offsets to apply to the position.
    func align(
        _ nodeAnchor: HRT2DPositionAnchor? = nil,
        withSubtree: Bool = true,
        to guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        withGuideSubtree: Bool = false,
        constants: CGPoint = .zero
    ) {
        let position: CGPoint?

        if let nodeAnchor = nodeAnchor {
            position = SKNode.position(
                for: self,
                at: nodeAnchor,
                withSubtree: withSubtree,
                matching: guideAnchor,
                of: guide,
                withGuideSubtree: withGuideSubtree,
                constants: constants
            )
        } else {
            position = SKNode.position(
                for: self,
                matching: guideAnchor,
                of: guide,
                withGuideSubtree: withGuideSubtree,
                constants: constants
            )
        }

        if let position = position { self.position = position }
    }

}
