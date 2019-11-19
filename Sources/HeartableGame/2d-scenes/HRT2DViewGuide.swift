// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

/// A node that is always positioned in the center of its parent, with the same size as its view
/// scaled to aspect-fit its scene (so that the scene aspect-fills the view).
open class HRT2DViewGuide: SKSpriteNode {

    // MARK: - Props

    // MARK: Config

    /// Custom insets. Safe-area-sensitive.
    public var margins: HRTInsets = .zero {
        didSet { layout() }
    }

    #if !os(macOS)

    /// If true, insets to safe area.
    public var insetsToSafeArea = true {
        didSet { layout() }
    }

    #endif

    // MARK: Geometry

    override public var frame: CGRect {
        return _frame
    }

    private var _frame: CGRect = .zero

}

// MARK: - HRTLayoutCapable conformance

extension HRT2DViewGuide: HRTLayoutCapable {

    public func layout() {
        #if !os(macOS)
        guard let viewGuide = viewGuide(
            insetsToSafeArea ? .safeAreaLimited : .full,
            margins: margins
        ) else { return }
        #else
        guard let viewGuide = viewGuide(margins: margins) else { return }
        #endif

        size = viewGuide.size
        _frame = viewGuide
    }

}
