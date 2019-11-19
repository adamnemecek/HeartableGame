// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation

public enum HRT2DViewGuideMode {

    case full

    #if !os(macOS)
    case safeAreaLimited
    #endif

}
