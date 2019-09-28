// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit

@available(iOS 9.0, *)
public protocol HRTGameplayBased {

    var entities: Set<GKEntity> { get set }

}
