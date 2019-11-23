// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

#if !os(macOS)
import UIKit
#endif

/// A button node.
///
/// - Note:
///     - Subclass for customization.
///     - To respond to button triggers, the scene must implement `HRT2DButtonResponder`.
open class HRT2DButton: SKSpriteNode {

    // MARK: - Props

    open var responder: HRT2DButtonResponder? { scene as? HRT2DButtonResponder }

    #if !os(macOS)
    open weak var touchDelegate: HRT2DButtonTouchDelegate?
    #endif

    // Texture
    open lazy var defaultTexture = texture
    open lazy var selectedTexture = texture

    open var focusableNeighbors = [HRT2DGameInputDirection : HRT2DButton]()

    // MARK: Config

    // Highlight
    open var onHighlightAction: SKAction?
    open var offHighlightAction: SKAction?

    // MARK: State

    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            removeAllActions()

            if isHighlighted {
                if let action = onHighlightAction { run(action) }
            } else {
                if let action = offHighlightAction { run(action) }
            }
        }
    }

    open var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }

    open var isFocused: Bool = false {
        didSet {}
    }

    // MARK: - Init

    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }

    // MARK: - Functionality

    open func trigger() {
        if isUserInteractionEnabled { responder?.buttonDidTrigger(self) }
    }

    #if !os(macOS)

    // MARK: - Touch

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
        touchDelegate?.button(self, didBegin: touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false

        if containsTouches(touches) {
            // Detected touch-up-inside.
            touchDelegate?.button(self, didEndInside: touches, with: event)
            trigger()
        } else {
            touchDelegate?.button(self, didEndOutside: touches, with: event)
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
        touchDelegate?.button(self, didCancel: touches, with: event)
    }

    open func containsTouches(_ touches: Set<UITouch>) -> Bool {
        guard let scene = scene else { return false }
        return touches.contains { touch in
            let point = touch.location(in: scene)
            let node = scene.atPoint(point)
            return node === self || node.inParentHierarchy(self)
        }
    }

    #else

    // MARK: - Mouse

    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isHighlighted = true
    }

    override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        isHighlighted = false

        if containsLocation(of: event) {
            // Detected mouse click, so trigger the button.
            trigger()
        }
    }

    open func containsLocation(of event: NSEvent) -> Bool {
        guard let scene = scene else { return false }
        let point = event.location(in: scene)
        let node = scene.atPoint(point)
        return node == self || node.inParentHierarchy(self)
    }

    #endif

    // MARK: - Focus

    open func runInvalidFocusChangeAction(_ direction: HRT2DGameInputDirection) {}

}
