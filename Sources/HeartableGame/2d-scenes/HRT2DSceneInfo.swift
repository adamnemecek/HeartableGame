// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics
import Foundation

/// The metadata of an `HRT2DScene`.
public struct HRT2DSceneInfo {

    /// This scene's identifier.
    let sceneKey: String

    /// The base name (no file extensions) of the associated scene file.
    let fileName: String

    /// The scene class to initiate from this metadata.
    let sceneType: HRT2DScene.Type

    /// If true, this scene is not automatically released from memory.
    let longLived: Bool

}

// MARK: - Hashable conformance

extension HRT2DSceneInfo: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sceneKey)
    }

    public static func == (lhs: HRT2DSceneInfo, rhs: HRT2DSceneInfo) -> Bool {
        lhs.sceneKey == rhs.sceneKey
    }

}
