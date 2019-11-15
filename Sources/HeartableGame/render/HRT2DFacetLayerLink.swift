// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public protocol HRT2DFacetLayerLink {

    associatedtype Facet: Hashable

    associatedtype LayerKey: Hashable

    static func layerKey(for facet: Facet) -> LayerKey

}
