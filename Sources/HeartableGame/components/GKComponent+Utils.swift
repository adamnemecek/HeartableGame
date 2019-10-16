// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit

public extension GKComponent {

    static var typeID: ObjectIdentifier { return ObjectIdentifier(self) }

    var typeID: ObjectIdentifier { return ObjectIdentifier(Self.self) }

}
