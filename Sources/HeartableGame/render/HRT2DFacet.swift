// Copyright © 2019 Heartable LLC. All rights reserved.

public protocol HRT2DFacet: CaseIterable, Hashable {

    static var `default`: Self { get }

    var stringValue: String { get }

}

public extension HRT2DFacet where Self: RawRepresentable, Self.RawValue == String {

    var stringValue: String { return self.rawValue }

}
