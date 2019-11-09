// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable

public protocol HRTAssetsLoading {

    static var typeID: ObjectIdentifier { get }

    /// True iff assets should be loaded (i.e. false if assets are already loaded).
    static var shouldLoadAssets: Bool { get }

    /// Dependencies with assets to load.
    static var assetsLoadingDependencies: [HRTAssetsLoading.Type] { get }

    /// Performs loading of assets.
    ///
    /// - Important: `completion` must be called when loading is complete.
    /// - Parameter completion: The completion handler.
    static func loadAssets(completion: @escaping HRTBlock)

    /// Releases loaded assets from memory.
    static func unloadAssets()

}

public extension HRTAssetsLoading {

    // MARK: - Impl

    static var typeID: ObjectIdentifier { ObjectIdentifier(Self.self) }

    // MARK: - Auxiliary

    /// All assets-loading dependencies in the dependency graph.
    static var allAssetsLoadingDependencies: [HRTAssetsLoading.Type] {
        assetsLoadingDependencies.isEmpty
            ? []
            : assetsLoadingDependencies.flatMap { $0.allAssetsLoadingDependencies + [$0] }
    }

}
