// Copyright © 2019 Heartable LLC. All rights reserved.

public protocol HRT2DSceneLoaderDelegate: AnyObject {

    func sceneLoaderDidLoad(_ sceneLoader: HRT2DSceneLoader, scene: HRT2DScene)

    func sceneLoaderDidFail(_ sceneLoader: HRT2DSceneLoader)

}
