// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable

public class HRTLoad2DSceneOperation: HRTOperation {

    // MARK: - Props

    public let info: HRT2DSceneInfo

    public var scene: HRT2DScene?

    public lazy var progress = Progress(totalUnitCount: 1)

    // MARK: - Init

    public init(_ info: HRT2DSceneInfo) {
        self.info = info
        super.init()
    }

    // MARK: - Lifecycle

    public override func main() {
        guard !isCancelled,
            !progress.isCancelled
        else {
            finish(with: [makeError(.executionFailed)])
            return
        }

        if let selfMakingSceneType = info.sceneType as? (HRT2DScene & HRTSelfMaking).Type {
            scene = selfMakingSceneType.make()
        } else {
            scene = info.sceneType.init(fileNamed: info.fileName)
        }

        if scene == nil { finish(with: [makeError(.executionFailed)]) }

        scene?.config(info)
        progress.completedUnitCount = 1
        finish()
    }

}
