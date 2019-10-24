// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public struct HRT2DSceneInfoDraft: Decodable {

    /// Key that uniquely identifies this scene.
    var sceneKey: String

    /// Name of the resource file containing this scene.
    var fileName: String

    /// If true, a progress scene is presented while this scene loads.
    var sceneChange: Bool?

    /// If true, this scene is not automatically released from memory.
    var longLived: Bool?

    /// List of the next scenes in the game's narrative.
    var nextSceneKeys: [String]

    private enum CodingKeys: String, CodingKey {
        case sceneKey
        case fileName
        case sceneChange
        case longLived
        case nextSceneKeys = "next"
    }

}
