// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

/// Interface for control input.
public final class HRT2DGameInput {

    // TODO: Extend for tvOS and game controllers.

    // MARK: - Props

    public weak var delegate: HRT2DGameInputDelegate? {
        didSet { delegate?.inputDidUpdateSources(self) }
    }

    public let nativeSource: HRT2DGameInputSource?

    public internal(set) var secondarySources = [HRT2DGameInputSource]()

    public var sources: [HRT2DGameInputSource] {
        if let nativeSource = nativeSource {
            return [nativeSource] + secondarySources
        } else {
            return secondarySources
        }
    }

    // MARK: - Init

    public init(_ nativeSource: HRT2DGameInputSource? = nil) {
        self.nativeSource = nativeSource
    }

    // MARK: - Functionality

    public func addSecondarySource(_ source: HRT2DGameInputSource) {
        secondarySources.append(source)
        delegate?.inputDidUpdateSources(self)
    }

    public func removeSecondarySource(_ source: HRT2DGameInputSource) {
        secondarySources.removeAll { $0 === source }
        delegate?.inputDidUpdateSources(self)
    }

}
