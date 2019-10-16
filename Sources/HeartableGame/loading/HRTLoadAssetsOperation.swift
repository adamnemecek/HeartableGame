// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable

public class HRTLoadAssetsOperation: HRTOperation {

    // MARK: - Props

    public let loadingType: HRTAssetsLoading.Type

    public var progress = Progress(totalUnitCount: 1)

    // MARK: - Init

    public init(loadingType: HRTAssetsLoading.Type) {
        self.loadingType = loadingType
        super.init()
    }

    // MARK: - Lifecycle

    public override func main() {
        guard !isCancelled,
            !progress.isCancelled
        else {
            finish(with: [makeError(.executionFailed)])
            return
        }

        guard loadingType.shouldLoadAssets else {
            progress.completedUnitCount = 1
            finish()
            return
        }

        loadingType.loadAssets {
            self.progress.completedUnitCount = 1
            self.finish()
        }
    }

}
