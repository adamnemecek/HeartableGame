// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable
import SpriteKit

open class HRT2DProgressScene: HRT2DScene, HRTFileBased, HRTSelfMaking {

    // MARK: - Constants

    open class var backgroundNodeName: String { "backgroundNode" }
    open class var labelNodeName: String { "labelNode" }
    open class var progressNodeName: String { "progressNode" }

    // MARK: - Creational

    /// Creates a progress scene via `init?(fileNamed:)` (which is a convenience initializer and
    /// thus cannot be overriden or delegated to from this subclass).
    open class func make() -> Self { Self(fileNamed: fileName)! }

    // MARK: - Props

    open var targetSceneInfo: HRT2DSceneInfo?

    // MARK: Nodes

    /// The root node of progress-related contents.
    open var backgroundNode: SKSpriteNode? {
        childNode(withName: Self.backgroundNodeName) as? SKSpriteNode
    }

    /// Node for progress description text.
    open var labelNode: SKLabelNode? {
        backgroundNode?.childNode(withName: Self.labelNodeName) as? SKLabelNode
    }

    /// Node for progress visualization.
    open var progressNode: HRT2DProgressRepresentable? {
        backgroundNode?.childNode(withName: Self.progressNodeName) as? HRT2DProgressRepresentable
    }

    // MARK: - Functionality

    open func wrapUp(_ completion: @escaping HRTBlock) {
        if let progressAction = progressNode?.progressAction {
            let duration = Double(progressAction.speed) * progressAction.duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { completion() }
        } else {
            completion()
        }
    }

    open func reset() {
        targetSceneInfo = nil
        progressNode?.resetProgress()
        labelNode?.text = nil
    }

    open func reportProgress(_ progress: Progress, completion: HRTBlock? = nil) {
        labelNode?.text = progress.localizedDescription
        progressNode?.updateProgress(
            progress.fractionCompleted,
            animated: true,
            completion: completion
        )
    }

    open func reportFailure() {}

}