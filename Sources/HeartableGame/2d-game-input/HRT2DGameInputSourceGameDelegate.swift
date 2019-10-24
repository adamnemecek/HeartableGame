// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DGameInputSourceGameDelegate: AnyObject {

    func inputSource(
        _ inputSource: HRT2DGameInputSource,
        didPickDirection direction: HRT2DGameInputDirection
    )
    func inputSourceDidSelect(_ inputSource: HRT2DGameInputSource)
    func inputSourceDidTogglePause(_ inputSource: HRT2DGameInputSource)

    #if DEBUG
    func inputSourceDidToggleDebugInfo(_ inputSource: HRT2DGameInputSource)
    func inputSourceDidTriggerWin(_ inputSource: HRT2DGameInputSource)
    func inputSourceDidTriggerLoss(_ inputSource: HRT2DGameInputSource)
    #endif

}
