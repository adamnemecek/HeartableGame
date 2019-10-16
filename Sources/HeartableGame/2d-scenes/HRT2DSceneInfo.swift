// Copyright © 2019 Heartable LLC. All rights reserved.

/// The metadata of an `HRT2DScene`.
public struct HRT2DSceneInfo {

    /// The base name (no file extensions) of any resource file associated with this scene.
    let fileName: String

    /// The scene class to initiate from this metadata.
    let sceneType: HRT2DScene.Type

    

}

// MARK: - Hashable conformance

extension HRT2DSceneInfo: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
    }

    public static func == (lhs: HRT2DSceneInfo, rhs: HRT2DSceneInfo) -> Bool {
        lhs.fileName == rhs.fileName
    }

}
