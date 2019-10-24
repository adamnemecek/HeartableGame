// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DGameInputDelegate: AnyObject {

    /// Indicates there are changes to the input's sources, e.g. the addition of a game controller.
    ///
    /// - Parameter input: The input.
    func inputDidUpdateSources(_ input: HRT2DGameInput)

}
