// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DUniFacetLayerLinkable: HRT2DFacetLayerLink {

    static var targetLayerKey: LayerKey { get }

}

public extension HRT2DUniFacetLayerLinkable {

    static func layerKey(for facet: HRT2DUniFacet = .default) -> LayerKey {
        targetLayerKey
    }

}
