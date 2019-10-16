// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

public protocol HRT2DNoded: HRTGameComponent {

    /// Nodes owned exclusively by this component (i.e. no shared nodes).
    var nodes: Set<SKNode> { get }

}
