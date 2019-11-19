// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public struct HRT2DSceneInfoDraft: Decodable {

    /// Key that uniquely identifies this scene.
    var sceneKey: String

    /// Name of the resource file containing this scene.
    var fileName: String

    /// If true, this scene is preloaded if possible.
    var preloads: Bool?

    /// If true, shows a loading progress scene if needed.
    var showsLoading: Bool?

    /// If true, shows a HUD overlay.
    var showsHUD: Bool?

    /// If true, this scene is not automatically released from memory.
    var isLongLived: Bool?

    /// If true, this scene contains elements that generate haptic feedback.
    var isHaptic: Bool?

    /// Describes whether this scene is primarily light- or dark-mode.
    var themeMode: String?

    /// List of the next scenes in the game's narrative.
    var nextSceneKeys: [String]?

    private enum CodingKeys: String, CodingKey {
        case sceneKey
        case fileName
        case preloads
        case showsLoading
        case showsHUD
        case isLongLived
        case isHaptic
        case themeMode
        case nextSceneKeys = "next"
    }

}
