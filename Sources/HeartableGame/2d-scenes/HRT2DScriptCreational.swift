// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable

public protocol HRT2DScriptCreational: CaseIterable, Hashable, RawRepresentable
where RawValue == String
{

    /// Name of the script property file.
    static var scriptName: String { get }

    /// The script instance described by this class.
    static var script: HRT2DScript { get set }

    /// All scenes keyed by instances of this class.
    static var scenes: HRTMap<Self, HRT2DSceneInfo> { get set }

    /// The scene keyed by this instance.
    var scene: HRT2DSceneInfo { get }

    /// The concrete class type of the scene keyed by this instance.
    var sceneType: HRT2DScene.Type { get }

}

public extension HRT2DScriptCreational {

    /// Populate `script` and `scenes` by extracting from resource data.
    ///
    /// - Important: Must be run before accessing `script` or `scenes`.
    ///
    /// - Parameter bundle: The bundle where the resource is stored.
    static func generate(bundle: Bundle = .main) {
        // Decode data.
        let url = bundle.url(forResource: scriptName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let drafts = try! PropertyListDecoder().decode([HRT2DSceneInfoDraft].self, from: data)

        // Construct convenience mapping.
        let stringKeyedScenesEntries = drafts.map { (
            $0.sceneKey,
            HRT2DSceneInfo(
                sceneKey: $0.sceneKey,
                fileName: $0.fileName,
                sceneType: Self(rawValue: $0.sceneKey)!.sceneType,
                sceneChange: $0.sceneChange ?? true,
                longLived: $0.longLived ?? false
            )
        ) }
        let stringKeyedScenes = Dictionary(stringKeyedScenesEntries) { _, last in last }

        // Construct scenes graph.
        var scenesGraph = [HRT2DSceneInfo: Set<HRT2DSceneInfo>]()
        drafts.forEach {
            let nextScenes = Set<HRT2DSceneInfo>(
                $0.nextSceneKeys.map { key in stringKeyedScenes[key]! }
            )
            scenesGraph[stringKeyedScenes[$0.sceneKey]!] = nextScenes
        }

        script = HRT2DScript(scenesGraph, openingScene: stringKeyedScenesEntries.first!.1)
        scenes = HRTMap<Self, HRT2DSceneInfo> { stringKeyedScenes[$0.rawValue]! }
    }

    // MARK: - Impl

    var scene: HRT2DSceneInfo { Self.scenes[self] }

}
