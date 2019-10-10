// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit

@available(iOS 10.0, macOS 10.11, *)
public protocol HRTGameplayBased {

    var entities: Set<GKEntity> { get set }

}