// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

#if !os(macOS)
import UIKit
#endif

open class HRT2DCurtain {

    // MARK: - Constants

    static let openActionName = "open"
    static let closeActionName = "close"

    // MARK: - Props

    let rootNode: HRT2DViewGuide

    // MARK: Config

    open var openAction: SKAction?
    open var closeAction: SKAction?

    // MARK: - Init

    #if !os(macOS)

    public init(_ color: UIColor) {
        rootNode = HRT2DViewGuide(color: color, size: .one)
        rootNode.position = .zero
    }

    #else

    public init(_ color: NSColor) {
        rootNode = HRT2DViewGuide(color: color, size: .one)
        rootNode.position = .zero
    }

    #endif

    // MARK: - Functionality

    open func attach(
        to parent: SKNode,
        mode: HRTScaleMode = .aspectFit,
        zPosition: CGFloat = .zero
    ) {
        rootNode.removeFromParent()
        rootNode.zPosition = zPosition
        parent.addChild(rootNode)
        rescale(mode)
    }

    open func detach() {
        rootNode.removeFromParent()
    }

    open func rescale(_ mode: HRTScaleMode = .aspectFit) {
        guard let scene = rootNode.scene,
            let view = scene.view
        else { return }

        let scaleFactors = CGSize.one.scaleFactors(to: view.size(in: scene), mode: mode)
        rootNode.xScale = scaleFactors.width
        rootNode.yScale = scaleFactors.height

        rootNode.layout()
    }

    open func open(_ action: SKAction? = nil, completion: HRTBlock? = nil) {
        rootNode.isHidden = false
        if let action = action ?? openAction {
            rootNode.run(.sequence([action, .run { completion?() }]), withKey: Self.openActionName)
        } else {
            completion?()
        }
    }

    open func close(_ action: SKAction? = nil, completion: HRTBlock? = nil) {
        if let action = action ?? closeAction {
            rootNode.run(.sequence([action, .run { completion?() }]), withKey: Self.closeActionName)
        } else {
            rootNode.isHidden = true
            completion?()
        }
    }

}

