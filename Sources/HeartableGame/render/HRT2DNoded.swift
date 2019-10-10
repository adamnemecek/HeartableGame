// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

@available(iOS 10.0, macOS 10.11, *)
public protocol HRT2DNoded: HRTGameComponent {

    /// Nodes owned exclusively by this component (i.e. no shared nodes).
    var nodes: Set<SKNode> { get }

}
