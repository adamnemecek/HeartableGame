// Copyright © 2019 Heartable LLC. All rights reserved.

public enum HRT2DSceneLoaderResult {
    case ongoing
    case success(HRT2DScene)
    case failure
}

// MARK: - Related

public typealias HRT2DSceneLoaderResultBlock = (HRT2DSceneLoaderResult) -> Void
