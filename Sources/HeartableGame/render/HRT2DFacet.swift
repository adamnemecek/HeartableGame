// Copyright © 2019 Heartable LLC. All rights reserved.

@available(iOS 10.0, *)
public protocol HRT2DFacet: CaseIterable, Hashable {

    static var `default`: Self { get }

    var stringValue: String { get }

}

@available(iOS 10.0, *)
public extension HRT2DFacet where Self: RawRepresentable, Self.RawValue == String {

    var stringValue: String { return self.rawValue }

}
