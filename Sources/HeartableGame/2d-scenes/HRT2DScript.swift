// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public class HRT2DScript {

    // MARK: - Props

    /// Scene orderings.
    public let scenesGraph: [HRT2DSceneInfo: Set<HRT2DSceneInfo>]

    /// The first scene.
    public let openingScene: HRT2DSceneInfo

    /// Set of scenes that aren't automatically released from memory.
    public let isLongLivedScenes: Set<HRT2DSceneInfo>

    // MARK: - Init

    public init(_ scenesGraph: [HRT2DSceneInfo: Set<HRT2DSceneInfo>], openingScene: HRT2DSceneInfo) {
        self.scenesGraph = scenesGraph
        self.openingScene = openingScene
        isLongLivedScenes = Set<HRT2DSceneInfo>(scenesGraph.keys.filter { $0.isLongLived })
    }

    // MARK: - Functionality

    /// Get all scenes that can come immediately after the specified scene.
    ///
    /// - Parameter sceneInfo: Info on the specified scene.
    /// - Returns: All possible next scenes.
    public func scenes(after sceneInfo: HRT2DSceneInfo?) -> Set<HRT2DSceneInfo> {
        guard let sceneInfo = sceneInfo else { return [openingScene] }
        return scenesGraph[sceneInfo] ?? []
    }

    /// Get all scenes that are reachable from the specified scene.
    ///
    /// - Parameter sceneInfo: Info on the specified scene.
    /// - Returns: All reachable scenes.
    public func scenes(reachableFrom sceneInfo: HRT2DSceneInfo) -> Set<HRT2DSceneInfo> {
        isLongLivedScenes
            .union(scenes(after: sceneInfo))
            .union([sceneInfo])
    }

    /// Get all scenes that are not reachable from the specified scene.
    ///
    /// - Parameter sceneInfo: Info on the specified scene.
    /// - Returns: All unreachable scenes.
    public func scenes(unreachableFrom sceneInfo: HRT2DSceneInfo) -> Set<HRT2DSceneInfo> {
        Set(scenesGraph.keys).subtracting(scenes(reachableFrom: sceneInfo))
    }

}
