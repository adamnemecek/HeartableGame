// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DProgressNode: SKSpriteNode {

    // MARK: - Constants

    open class var actionName: String { "progressionAction" }

    // MARK: - Props

    @HRTLate open var fillNode: SKSpriteNode

    @HRTLate open var startSize: CGSize

    @HRTLate open var fullWidth: CGFloat

    // MARK: - Config

    open var totalDuration: TimeInterval = 1

    open var timingMode: SKActionTimingMode = .easeOut

    // MARK: - Init

    #if !os(macOS)

    public init(
        texture: SKTexture? = nil,
        color: UIColor? = nil,
        startSize: CGSize,
        fullWidth: CGFloat
    ) {
        super.init(
            texture: nil,
            color: .clear,
            size: CGSize(width: fullWidth, height: startSize.height)
        )

        self.startSize = startSize
        self.fullWidth = fullWidth

        if let texture = texture {
            fillNode = SKSpriteNode(texture: texture, size: startSize)
        } else if let color = color {
            fillNode = SKSpriteNode(color: color, size: startSize)
        } else {
            fillNode = SKSpriteNode(texture: nil, size: startSize)
        }

        setUp()
    }

    #else

    public init(
        texture: SKTexture? = nil,
        color: NSColor? = nil,
        startSize: CGSize,
        fullWidth: CGFloat
    ) {
        super.init(
            texture: nil,
            color: .clear,
            size: CGSize(width: fullWidth, height: startSize.height)
        )

        self.startSize = startSize
        self.fullWidth = fullWidth

        if let texture = texture {
            fillNode = SKSpriteNode(texture: texture, size: startSize)
        } else if let color = color {
            fillNode = SKSpriteNode(color: color, size: startSize)
        } else {
            fillNode = SKSpriteNode(texture: nil, size: startSize)
        }

        setUp()
    }

    #endif

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startSize = CGSize(width: texture?.size().width ?? 0, height: size.height)
        fullWidth = size.width
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

    open func setFillNodeWidth(_ width: CGFloat) {
        fillNode.size.width = max(width, startSize.width)
    }

}

// MARK: - HRT2DProgressRepresentable

extension HRT2DProgressNode: HRT2DProgressRepresentable {

    open var progressAction: SKAction? { fillNode.action(forKey: Self.actionName) }

    open func resetProgress() {
        setFillNodeWidth(0)
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
            let duration = Double(dwFraction) * totalDuration

            let animation = SKAction.resize(
                toWidth: min(max(newWidth, startSize.width), fullWidth),
                duration: duration
            )
            animation.timingMode = timingMode

            let action = SKAction.sequence([animation, .run { completion?() }])
            action.speed *= fractionCompleted == 1 ? 2 : 1

            fillNode.run(action, withKey: Self.actionName)
        } else {
            setFillNodeWidth(newWidth)
            completion?()
        }
    }

    open func rescale(fullWidth: CGFloat) {
        let currFillFraction = fillNode.frame.width / frame.width
        let newFillWidth = currFillFraction * fullWidth
        setFillNodeWidth(newFillWidth)
        size.width = fullWidth
    }

}
