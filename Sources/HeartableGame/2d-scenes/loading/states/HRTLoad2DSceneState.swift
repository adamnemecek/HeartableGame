// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
import Foundation

public class HRTLoad2DSceneState: GKState {

    // MARK: - Props

    public unowned let loader: HRT2DSceneLoader

    // MARK: - Init

    public init(governing loader: HRT2DSceneLoader) {
        self.loader = loader
    }

}
