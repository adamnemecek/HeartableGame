// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DProgressNode: SKSpriteNode {

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
    }

}

// MARK: - HRT2DProgressRepresentable

extension HRT2DProgressNode: HRT2DProgressRepresentable {

    open func updateProgress(_ fractionCompleted: Double) {
        fillNode.size.width = frame.width * CGFloat(fractionCompleted)
    }

}
