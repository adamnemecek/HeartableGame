// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DProgressEntity: HRTGameEntity, HRT2DRenderable {

    // MARK: - Types

    public enum Facet: String, HRT2DFacet {
        public static var `default` = Self.fill
        case fill, background
    }

    public class BGComponent: HRT2DRenderComponent {}

    // MARK: - Constants

    open class var actionName: String { "progressionAction" }

    // MARK: - Props

    open var componentInfo = ComponentInfo()

    @HRTLate open internal(set) var fillNode: SKSpriteNode

    @HRTLate open internal(set) var bgNode: SKSpriteNode

    open internal(set) var fullSize: CGSize

    open internal(set) var minFillWidth: CGFloat

    open internal(set) var fractionCompleted: Double = 0

    open internal(set) var insets: HRTInsets

    open var fullFillWidth: CGFloat { fullSize.width - insets.left - insets.right }

    open var fullFillHeight: CGFloat { fullSize.height - insets.top - insets.bottom }

    // MARK: Config

    open var totalDuration: TimeInterval = 1

    open var timingMode: SKActionTimingMode = .easeOut

    // MARK: - Init

    public init(
        fullSize: CGSize,
        minFillWidth: CGFloat,
        fillNode: SKSpriteNode,
        bgNode: SKSpriteNode? = nil,
        insets: HRTInsets = .zero
    ) {
        self.fullSize = fullSize
        self.minFillWidth = minFillWidth
        self.insets = insets
        super.init()

        // Background component

        let bgComponent = BGComponent()
        addNodedComponent(bgComponent, facet: .background)

        if let bgNode = bgNode {
            self.bgNode = bgNode
            bgNode.removeFromParent()
            bgNode.size = fullSize
        } else {
            self.bgNode = SKSpriteNode(color: .clear, size: fullSize)
        }
        bgComponent.node.addChild(self.bgNode)

        // Fill component

        let fillComponent = HRT2DRenderComponent()
        addNodedComponent(fillComponent, facet: .fill)

        self.fillNode = fillNode
        fillNode.size = CGSize(width: fullFillWidth, height: fullFillHeight)
        fillNode.removeFromParent()
        fillComponent.node.addChild(fillNode)
        setFillNodePosition()

        // Reset

        resetProgress()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Utils

    open func setFill(_ fractionCompleted: Double) {
        fillNode.size.width = getFillWidth(fractionCompleted)
    }

    open func getFillWidth(_ fractionCompleted: Double) -> CGFloat {
        // Cache computed width property.
        let fullFillWidth = self.fullFillWidth
        let width = CGFloat(fractionCompleted) * fullFillWidth
        return min(max(width, minFillWidth), fullFillWidth)
    }

    open func setFillNodePosition() {
        // Set `fillNode` to align to the leftmost midpoint so that progress grows toward the right.
        fillNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillNode.position = CGPoint(
            x: -(fullSize.width / 2) + insets.left,
            y: -(insets.top - insets.bottom) / 2
        )
    }

}

extension HRT2DProgressEntity: HRT2DProgressRepresentable {

    open var progressAction: SKAction? { fillNode.action(forKey: Self.actionName) }

    open func resetProgress() {
        setFill(0)
    }

    open func updateProgress(
        _ fractionCompleted: Double,
        animated: Bool = true,
        completion: HRTBlock? = nil
    ) {
        self.fractionCompleted = fractionCompleted

        if animated {
            let oldWidth = fillNode.frame.width
            let newWidth = getFillWidth(fractionCompleted)
            let dw = abs(newWidth - oldWidth)
            let dwFraction = dw / fullSize.width
            let duration = Double(dwFraction) * totalDuration

            let animation = SKAction.resize(toWidth: newWidth, duration: duration)
            animation.timingMode = timingMode

            let action = SKAction.sequence([animation, .run { completion?() }])
            action.speed *= fractionCompleted == 1 ? 2 : 1

            fillNode.run(action, withKey: Self.actionName)
        } else {
            setFill(fractionCompleted)
            completion?()
        }
    }

    open func rescale(fullWidth: CGFloat) {
        fullSize.width = fullWidth
        bgNode.size.width = fullWidth
        setFillNodePosition()
        setFill(fractionCompleted)
    }

}
