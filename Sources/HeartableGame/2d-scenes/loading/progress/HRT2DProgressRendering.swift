// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

public protocol HRT2DProgressRendering: HRT2DScene {

    // MARK: - Props

    var targetSceneInfo: HRT2DSceneInfo? { get set }
    
    /// Label of progress.
    var progressLabel: HRT2DProgressLabeling? { get }

    /// Visualization of progress.
    var progressVisual: HRT2DProgressRepresentable? { get }

    // MARK: - Functionality

    func wrapUp(_ completion: @escaping HRTBlock)
    func reset()
    func reportProgress(_ progress: Progress, completion: HRTBlock?)
    func reportFailure()

}

public extension HRT2DProgressRendering {

    // MARK: - Functionality impl

    func wrapUp(_ completion: @escaping HRTBlock) {
        if let progressAction = progressVisual?.progressAction {
            DispatchQueue.main.asyncAfter(deadline: .now() + progressAction.duration) {
                completion()
            }
        } else {
            completion()
        }
    }

    func reset() {
        targetSceneInfo = nil
        progressVisual?.resetProgress()
        progressLabel?.text = nil
    }

    func reportProgress(_ progress: Progress, completion: HRTBlock? = nil) {
        progressLabel?.text = progress.localizedDescription
        progressVisual?.updateProgress(
            progress.fractionCompleted,
            animated: true,
            completion: completion
        )
    }

    func reportFailure() {}

}

public extension HRT2DProgressRendering where Self: HRTFileBased, Self: HRTSelfMaking {

    static func make() -> Self { Self(fileNamed: fileName)! }

}
