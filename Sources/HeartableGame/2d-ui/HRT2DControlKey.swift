// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DControlKey: HRT2DNodeKey {

    var defaultTextureName: String { get }

    var highlightedTextureName: String? { get }

    var selectedTextureName: String? { get }

}

public extension HRT2DControlKey where Self: RawRepresentable, Self.RawValue == String {

    var defaultTextureName: String { self.rawValue }

    var highlightedTextureName: String? { nil }

    var selectedTextureName: String? { nil }

}
