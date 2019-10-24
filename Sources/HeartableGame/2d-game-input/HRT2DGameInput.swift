// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

/// Interface for control input.
public final class HRT2DGameInput {

    // TODO: Extend for tvOS and game controllers.

    // MARK: - Props

    public weak var delegate: HRT2DGameInputDelegate? {
        didSet { delegate?.inputDidUpdateSources(self) }
    }

    public let nativeSource: HRT2DGameInputSource

    public var sources: [HRT2DGameInputSource] { [nativeSource] }

    // MARK: - Init

    public init(_ nativeSource: HRT2DGameInputSource) {
        self.nativeSource = nativeSource
    }

}
