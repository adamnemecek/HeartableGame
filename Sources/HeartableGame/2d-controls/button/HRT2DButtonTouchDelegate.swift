// Copyright © 2019 Heartable LLC. All rights reserved.

#if !os(macOS)

import Foundation
import UIKit

public protocol HRT2DButtonTouchDelegate: AnyObject {

    func button(_ button: HRT2DButton, didBegin touches: Set<UITouch>, with event: UIEvent?)

    func button(_ button: HRT2DButton, didEndOutside touches: Set<UITouch>, with event: UIEvent?)

    func button(_ button: HRT2DButton, didEndInside touches: Set<UITouch>, with event: UIEvent?)

    func button(_ button: HRT2DButton, didCancel touches: Set<UITouch>, with event: UIEvent?)

}

public extension HRT2DButtonTouchDelegate {

    func button(_ button: HRT2DButton, didBegin touches: Set<UITouch>, with event: UIEvent?) {}

    func button(_ button: HRT2DButton, didEndOutside touches: Set<UITouch>, with event: UIEvent?) {}

    func button(_ button: HRT2DButton, didEndInside touches: Set<UITouch>, with event: UIEvent?) {}

    func button(_ button: HRT2DButton, didCancel touches: Set<UITouch>, with event: UIEvent?) {}

}

#endif
