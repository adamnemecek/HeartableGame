// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DProgressNode: SKSpriteNode {

    // MARK: - Constants

    open class var actionName: String { "progressionAction" }
    open class var totalDuration: TimeInterval { 2 }
    open class var actionTimingMode: SKActionTimingMode { .easeOut }

    // MARK: - Props

    @HRTLate open private(set) var fillNode: SKSpriteNode

    // MARK: - Init

    #if !os(macOS)

    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        fillNode = SKSpriteNode(texture: texture, color: color, size: size)
        setUp()
    }

    #else

    public override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        fillNode = SKSpriteNode(texture: texture, color: color, size: size)
        setUp()
    }

    #endif

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fillNode = SKSpriteNode(texture: texture, color: color, size: size)
        texture = nil
        color = .clear
        setUp()
    }

    // MARK: - Utils

    open func setUp() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // Set `fillNode` to align to the leftmost midpoint so that progress grows toward the right.
        fillNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillNode.position = CGPoint(x: -size.width / 2, y: 0)
        addChild(fillNode)

        resetProgress()
    }

}

// MARK: - HRT2DProgressRepresentable

extension HRT2DProgressNode: HRT2DProgressRepresentable {

    open var progressAction: SKAction? { fillNode.action(forKey: Self.actionName) }

    open func resetProgress() {
        fillNode.size = CGSize(width: 0, height: fillNode.size.height)
    }

    open func updateProgress(
        _ fractionCompleted: Double,
        animated: Bool = true,
        completion: HRTBlock? = nil
    ) {
        let oldWidth = fillNode.frame.width
        let newWidth = frame.width * CGFloat(fractionCompleted)

        if animated {
            let dw = abs(newWidth - oldWidth)
            let dwFraction = dw / frame.width
            let duration = Double(dwFraction) * Self.totalDuration
            let action = SKAction.resize(toWidth: newWidth, duration: duration)
            action.timingMode = Self.actionTimingMode
            action.speed *= fractionCompleted == 1 ? 2 : 1
            fillNode.run(.sequence([action, .run { completion?() }]), withKey: Self.actionName)
        } else {
            fillNode.size.width = newWidth
            completion?()
        }
    }

}
