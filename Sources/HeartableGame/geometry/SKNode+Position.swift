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
    ///     - offsets: Offsets to apply to the position.
    /// - Returns: The position of `point` in `node`'s parent's coordinate space.
    static func position(
        for node: SKNode,
        matching point: CGPoint,
        in guide: SKNode? = nil,
        offsets: CGPoint = .zero
    ) -> CGPoint? {
        guard let nodeParent = node.parent else { return nil }
        let target = guide ?? nodeParent
        let convertedPoint = nodeParent.convert(point, from: target)
        return convertedPoint + offsets
    }

    /// Calculates the position (in `node`'s parent's coordinate space) of the specified anchor
    /// on `guide`.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - guideAnchor: The anchor on `guide`. If nil, defaults to `guide`'s position.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - offsets: Offsets to apply to the position.
    ///     - guideFrameMode: Frame mode of `guide`.
    /// - Returns: The position of the specified anchor in `node`'s parent's coordinate space, or
    ///     nil if not calculable.
    static func position(
        for node: SKNode,
        matching guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        offsets: CGPoint = .zero,
        guideFrameMode: HRT2DFrameMode = .singular
    ) -> CGPoint? {
        guard let nodeParent = node.parent else { return nil }

        let target = guide ?? nodeParent
        let targetParent = target.parent ?? target

        guard let guideAnchor = guideAnchor else {
            // No guide anchor is provided, so simply use the guide's position.
            let convertedTargetPosition = nodeParent.convert(target.position, from: targetParent)
            return convertedTargetPosition + offsets
        }

        // Find the minimum point (i.e. the bottom-leftmost point) in the target's parent's
        // coordinate space.
        let targetFrame = target.frame(guideFrameMode)
        let targetMin = CGPoint(x: targetFrame.minX, y: targetFrame.minY)

        // Convert the minimum point to `node`'s parent's coordinate space.
        let convertedTargetMin = nodeParent.convert(targetMin, from: targetParent)

        // Find the position of the target anchor.
        let guideAnchorUnitPoint = guideAnchor.unitPoint(in: target, frameMode: guideFrameMode)
        let convertedTargetAnchorPosition = CGPoint(
            x: convertedTargetMin.x + (targetFrame.width * guideAnchorUnitPoint.x),
            y: convertedTargetMin.y + (targetFrame.height * guideAnchorUnitPoint.y)
        )

        // Apply offsets and return the final position.
        return convertedTargetAnchorPosition + offsets
    }

    /// Calculates the position (in `node`'s parent's coordinate space) that, if assigned to node,
    /// would place the specified `nodeAnchor` onto the specified `point`.
    ///
    /// - Parameters:
    ///     - node: The node.
    ///     - nodeAnchor: The anchor on `node`.
    ///     - point: The target point in `guide`'s coordinate space.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - offsets: Offsets to apply to the position.
    ///     - nodeFrameMode: Frame mode of `node`.
    /// - Returns: The position as described, or nil if not calculable.
    static func position(
        for node: SKNode,
        at nodeAnchor: HRT2DPositionAnchor,
        matching point: CGPoint,
        in guide: SKNode? = nil,
        offsets: CGPoint = .zero,
        nodeFrameMode: HRT2DFrameMode = .accumulated
    ) -> CGPoint? {
        guard let pointPosition = position(
            for: node,
            matching: point,
            in: guide,
            offsets: offsets
        )
        else { return nil }

        let nodeFrame = node.frame(nodeFrameMode)

        // Find the minimum point of `node` in its parent's coorindate space.
        let nodeMin = CGPoint(x: nodeFrame.minX, y: nodeFrame.minY)

        // Find the position of the specified `node` anchor.
        let nodeAnchorUnitPoint = nodeAnchor.unitPoint(in: node, frameMode: nodeFrameMode)
        let nodeAnchorPosition = CGPoint(
            x: nodeMin.x + (nodeFrame.width * nodeAnchorUnitPoint.x),
            y: nodeMin.y + (nodeFrame.height * nodeAnchorUnitPoint.y)
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
    ///     - guideAnchor: The anchor on `guide`. If nil, defaults to `guide`'s position.
    ///     - guide: The target node. If nil, defaults to `node`'s parent.
    ///     - offsets: Offsets to apply to the position.
    ///     - nodeFrameMode: Frame mode of `node`.
    ///     - guideFrameMode: Frame mode of `guide`.
    /// - Returns: The position as described, or nil if not calculable.
    static func position(
        for node: SKNode,
        at nodeAnchor: HRT2DPositionAnchor,
        matching guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        offsets: CGPoint = .zero,
        nodeFrameMode: HRT2DFrameMode = .accumulated,
        guideFrameMode: HRT2DFrameMode = .singular
    ) -> CGPoint? {
        guard let guideAnchorPosition = position(
            for: node,
            matching: guideAnchor,
            of: guide,
            offsets: offsets,
            guideFrameMode: guideFrameMode
        )
        else { return nil }

        let nodeFrame = node.frame(nodeFrameMode)

        // Find the minimum point of `node` in its parent's coorindate space.
        let nodeMin = CGPoint(x: nodeFrame.minX, y: nodeFrame.minY)

        // Find the position of the specified `node` anchor.
        let nodeAnchorUnitPoint = nodeAnchor.unitPoint(in: node, frameMode: nodeFrameMode)
        let nodeAnchorPosition = CGPoint(
            x: nodeMin.x + (nodeFrame.width * nodeAnchorUnitPoint.x),
            y: nodeMin.y + (nodeFrame.height * nodeAnchorUnitPoint.y)
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
    ///     - point: The target point in `guide`'s coordinate space.
    ///     - guide: The target node. If nil, defaults to this node's parent.
    ///     - offsets: Offsets to apply to the position.
    ///     - nodeFrameMode: Frame mode of `node`.
    func align(
        _ nodeAnchor: HRT2DPositionAnchor? = nil,
        to point: CGPoint,
        in guide: SKNode? = nil,
        offsets: CGPoint = .zero,
        nodeFrameMode: HRT2DFrameMode = .accumulated
    ) {
        let position: CGPoint?

        if let nodeAnchor = nodeAnchor {
            position = SKNode.position(
                for: self,
                at: nodeAnchor,
                matching: point,
                in: guide,
                offsets: offsets,
                nodeFrameMode: nodeFrameMode
            )
        } else {
            position = SKNode.position(
                for: self,
                matching: point,
                in: guide,
                offsets: offsets
            )
        }

        if let position = position { self.position = position }
    }

    /// Aligns this node to `guide`, based on the specified `nodeAnchor` and `guideAnchor`.
    ///
    /// - Parameters:
    ///     - nodeAnchor: The anchor on `node` to align with. If nil, uses SKNode's inherent
    ///       `anchorPoint`.
    ///     - guideAnchor: The anchor on `guide` to align to. If nil, defaults to `guide`'s
    ///         position.
    ///     - guide: The target node. If nil, defaults to this node's parent.
    ///     - offsets: Offsets to apply to the position.
    ///     - nodeFrameMode: Frame mode of `node`.
    ///     - guideFrameMode: Frame mode of `guide`.
    func align(
        _ nodeAnchor: HRT2DPositionAnchor? = nil,
        to guideAnchor: HRT2DPositionAnchor?,
        of guide: SKNode? = nil,
        offsets: CGPoint = .zero,
        guideFrameMode: HRT2DFrameMode = .singular,
        nodeFrameMode: HRT2DFrameMode = .accumulated
    ) {
        let position: CGPoint?

        if let nodeAnchor = nodeAnchor {
            position = SKNode.position(
                for: self,
                at: nodeAnchor,
                matching: guideAnchor,
                of: guide,
                offsets: offsets,
                nodeFrameMode: nodeFrameMode,
                guideFrameMode: guideFrameMode
            )
        } else {
            position = SKNode.position(
                for: self,
                matching: guideAnchor,
                of: guide,
                offsets: offsets,
                guideFrameMode: guideFrameMode
            )
        }

        if let position = position { self.position = position }
    }

}
