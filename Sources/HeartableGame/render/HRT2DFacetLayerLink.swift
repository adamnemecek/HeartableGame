// Copyright © 2019 Heartable LLC. All rights reserved.

import SpriteKit

@available(iOS 10.0, *)
public protocol HRT2DFacetLayerLink {

    associatedtype Facet: Hashable

    associatedtype LayerKey: Hashable

    static func layerKey(for facet: Facet) -> LayerKey

}
