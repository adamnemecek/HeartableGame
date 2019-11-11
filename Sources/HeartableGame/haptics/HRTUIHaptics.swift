// Copyright © 2019 Heartable LLC. All rights reserved.

#if !os(macOS)

import Foundation
import Heartable
import SpriteKit
import UIKit

public enum HRTUIHaptics {

    // MARK: - Props

    public static var impactEngine: UIImpactFeedbackGenerator?
    public static var noticeEngine: UINotificationFeedbackGenerator?
    public static var selectEngine: UISelectionFeedbackGenerator?

    // MARK: - Setup

    public static func setUp() {
        impactEngine = UIImpactFeedbackGenerator()
        noticeEngine = UINotificationFeedbackGenerator()
        selectEngine = UISelectionFeedbackGenerator()

        impactEngine?.prepare()
        noticeEngine?.prepare()
        selectEngine?.prepare()
    }

    public static func tearDown() {
        impactEngine = nil
        noticeEngine = nil
        selectEngine = nil
    }

}

#endif
