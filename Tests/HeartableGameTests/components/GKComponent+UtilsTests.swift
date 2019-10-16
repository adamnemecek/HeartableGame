// Copyright © 2019 Heartable LLC. All rights reserved.

import GameplayKit
@testable import HeartableGame
import XCTest

final class GKComponent_UtilsTests: XCTestCase {

    // MARK: - Prep

    class ComponentA: GKComponent {}

    // MARK: - Tests

    func testObjectIdentifier() {
        let componentAID = ObjectIdentifier(ComponentA.self)

        XCTAssert(ComponentA.typeID == componentAID)

        let component1 = ComponentA()
        XCTAssert(component1.typeID == componentAID)
    }

}
