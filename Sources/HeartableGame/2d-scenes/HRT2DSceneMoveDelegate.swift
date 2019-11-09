// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DSceneMoveDelegate: AnyObject {

    func sceneDidMove(_ scene: HRT2DScene)

    func sceneWillMove(_ scene: HRT2DScene)

}

public extension HRT2DSceneMoveDelegate {

    func sceneDidMove(_ scene: HRT2DScene) {}

    func sceneWillMove(_ scene: HRT2DScene) {}

}
