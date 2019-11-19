// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics
import Foundation
import Heartable

/// The metadata of an `HRT2DScene`.
public struct HRT2DSceneInfo {

    // MARK: - Props

    /// This scene's identifier.
    public let sceneKey: String

    /// The base name (no file extensions) of the associated scene file.
    public let fileName: String

    /// The scene class to initiate from this metadata.
    public let sceneType: HRT2DScene.Type

    /// If true, this scene is preloaded if possible.
    public var preloads: Bool

    /// If true, shows a loading progress scene if needed.
    public let showsLoading: Bool

    /// If true, shows a HUD overlay.
    public let showsHUD: Bool

    /// If true, this scene is not automatically released from memory.
    public let isLongLived: Bool

    /// If true, this scene contains elements that generate haptic feedback.
    public let isHaptic: Bool

    /// Describes whether this scene is primarily light- or dark-mode.
    public let themeMode: HRTThemeMode

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
