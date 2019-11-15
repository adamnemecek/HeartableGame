// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DUniFacetLayerLink: HRT2DFacetLayerLink {

    static var targetLayerKey: LayerKey { get }

}

public extension HRT2DUniFacetLayerLink {

    static func layerKey(for facet: HRT2DUniFacet = .default) -> LayerKey { targetLayerKey }

}
