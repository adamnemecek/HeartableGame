// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import SpriteKit

extension SKLabelNode: HRT2DBaselined {

    /// Returns the unit point of the (0, 0) point in this label node's coordinate space. Assuming
    /// `verticalAlignmentMode` is `.baseline`, this is the label's baseline unit point.
    ///
    /// - Parameter frameMode: Frame mode of this label node.
    /// - Returns: The baseline unit point (assuming `verticalAlignmentMode` is `.baseline`).
    public func baselineUnitPoint(frameMode: HRT2DFrameMode = .singular) -> CGPoint {
        return normalizedFrame(frameMode).unitPoint(of: .zero)
    }

    #if !os(macOS)

    /// Get the rect that symmetrically frames the text.
    ///
    /// - Parameter frameMode: Frame mode for the frame.
    /// - Returns: The symmetric rect.
    public func labelFrame(frameMode: HRT2DFrameMode = .singular) -> CGRect {
        if let attrString = attributedText,
            attrString.length > 0,
            let firstFont = attrString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        {
            // Determine the tallest font.
            var tallestFont = firstFont
            attrString.enumerateAttribute(
                .font,
                in: NSRange(location: 1, length: attrString.length - 1)
            ) { value, _, _ in
                guard let font = value as? UIFont else { return }
                if font.lineHeight > tallestFont.lineHeight { tallestFont = font }
            }
            // Using the tallest font, get the font frame.
            return calculateFontFrame(tallestFont, frameMode: frameMode)
        } else if let fontName = fontName,
            let font = UIFont(name: fontName, size: fontSize)
        {
            return calculateFontFrame(font, frameMode: frameMode)
        } else {
            return frame
        }

    }

    func calculateFontFrame(_ font: UIFont, frameMode: HRT2DFrameMode = .singular) -> CGRect {
        let labelFrame = frame(frameMode)

        // Assume `verticalAlignmentMode` is `.baseline`, so that the baseline rests on (0, 0).

        // Bottom y-coordinate extends to the descender.
        let bottomY = font.descender.rounded(.awayFromZero)

        // Top y-coordinate extends to the ascender.
        let topY = font.ascender.rounded(.awayFromZero)

        let fontFrameHeight = topY - bottomY
        let fontFrameOrigin = CGPoint(x: labelFrame.origin.x, y: bottomY)

        return CGRect(
            origin: fontFrameOrigin,
            size: CGSize(width: labelFrame.width, height: fontFrameHeight)
        )
    }

    #endif

}
