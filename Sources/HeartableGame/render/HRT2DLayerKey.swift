// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics

public protocol HRT2DLayerKey: CaseIterable, Hashable {

    static var pathPrefix: String { get }

    static var `default`: Self { get }

    var name: String { get }

    var path: String { get }

    var zPosition: CGFloat { get }

}

public extension HRT2DLayerKey where Self: RawRepresentable, Self.RawValue == CGFloat {

    static var pathPrefix: String { return "" }

    var name: String { return String(describing: self) }

    var path: String { return "\(Self.pathPrefix)\(name)" }

    var zPosition: CGFloat { return self.rawValue }

}
