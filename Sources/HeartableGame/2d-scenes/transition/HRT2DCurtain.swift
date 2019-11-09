// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

#if !os(macOS)
import UIKit
#endif

open class HRT2DCurtain {

    // MARK: - Constants

    static let actionName = "curtainAction"

    // MARK: - Props

    let rootNode: HRT2DViewGuide

    // MARK: Config

    open var openAction: SKAction?
    open var closeAction: SKAction?

    #if !os(macOS)

    open var preColor: UIColor {
        didSet { rootNode.color = preColor }
    }

    open var postColor: UIColor

    #else

    open var preColor: NSColor {
        didSet { rootNode.color = preColor }
    }

    open var postColor: NSColor

    #endif

    // MARK: - Init

    #if !os(macOS)

    public init(_ color: UIColor) {
        preColor = color
        postColor = color
        rootNode = HRT2DViewGuide(color: color, size: .one)
        rootNode.insetsToSafeArea = false
        rootNode.position = .zero
    }

    public init(preColor: UIColor, postColor: UIColor) {
        self.preColor = preColor
        self.postColor = postColor
        rootNode = HRT2DViewGuide(color: preColor, size: .one)
        rootNode.insetsToSafeArea = false
        rootNode.position = .zero
    }

    #else

    public init(_ color: NSColor) {
        preColor = color
        postColor = color
        rootNode = HRT2DViewGuide(color: color, size: .one)
        rootNode.position = .zero
    }

    public init(preColor: NSColor, postColor: NSColor) {
        self.preColor = preColor
        self.postColor = postColor
        rootNode = HRT2DViewGuide(color: preColor, size: .one)
        rootNode.position = .zero
    }

    #endif

    // MARK: - Functionality

    open func attach(
        to parent: SKCameraNode,
        mode: HRTScaleMode = .aspectFit,
        zPosition: CGFloat? = nil
    ) {
        rootNode.zPosition = zPosition ?? parent.zPosition
        rootNode.removeFromParent()
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

    open func close(_ action: SKAction? = nil, completion: HRTBlock? = nil) {
        if let action = action ?? closeAction {
            rootNode.run(.sequence([
                .group([
                    action,
                    .colorize(with: postColor, colorBlendFactor: 1, duration: action.duration)
                ]),
                .run { completion?() }
            ]), withKey: Self.actionName)
        } else {
            completion?()
        }
    }

    open func open(_ action: SKAction? = nil, completion: HRTBlock? = nil) {
        rootNode.color = preColor
        if let action = action ?? openAction {
            rootNode.run(.sequence([action, .run { completion?() }]), withKey: Self.actionName)
        } else {
            completion?()
        }
    }

}
