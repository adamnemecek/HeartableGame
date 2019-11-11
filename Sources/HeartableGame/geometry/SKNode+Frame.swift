// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
import SpriteKit

public extension SKNode {

    func frame(_ mode: HRT2DFrameMode) -> CGRect {
        switch mode {
        case .accumulated: return calculateAccumulatedFrame()
        case .singular: return frame
        }
    }

    func normalizedFrame(_ mode: HRT2DFrameMode) -> CGRect {
        let prevPosition = position

        // Set `position` to `.zero` to normalize the frame.
        position = .zero
        let normalizedFrame = frame(mode)

        // Set `position` back to its previous value.
        position = prevPosition

        return normalizedFrame
    }

}
