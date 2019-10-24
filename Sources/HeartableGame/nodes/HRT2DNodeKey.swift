// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DNodeKey: CaseIterable, Hashable {

    static var pathPrefix: String { get }

    init?(name: String)

    var name: String { get }

    var path: String { get }

}

public extension HRT2DNodeKey {

    static var pathPrefix: String { return "" }

    init?(name: String) {
        guard let key = Self.allCases.first(where: { $0.name == name }) else { return nil }
        self = key
    }

    var name: String { String(describing: self) }

    var path: String { "\(Self.pathPrefix)\(name)" }

}

public extension HRT2DNodeKey where Self: RawRepresentable, Self.RawValue == String {

    init?(name: String) {
        self.init(rawValue: name)
    }

    var name: String { rawValue }

}
