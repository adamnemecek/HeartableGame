// Copyright © 2019 Heartable LLC. All rights reserved.

/// Defines variants in the animation of an animation component, such as a walking animation variant
/// and a running animation variant of an animation component representing a character.
public protocol HRT2DAnimationVariant: CaseIterable, Hashable {

    static var `default`: Self { get }

    var stringValue: String { get }

}

public extension HRT2DAnimationVariant where Self: RawRepresentable, Self.RawValue == String {

    var stringValue: String { return self.rawValue }

}
