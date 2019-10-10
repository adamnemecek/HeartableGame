// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit

@available(iOS 9.0, macOS 10.11, *)
public extension GKComponent {

    static var typeID: ObjectIdentifier { return ObjectIdentifier(self) }

    var typeID: ObjectIdentifier { return ObjectIdentifier(Self.self) }

}
