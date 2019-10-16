// Copyright © 2019 Heartable LLC. All rights reserved.

import Foundation
import Heartable

public class HRTAssetsLoader {

    // MARK: - Props

    public private(set) var progress: Progress?

    public let loadingTypes: [HRTAssetsLoading.Type]

    public var qualityOfService: QualityOfService = .utility {
        didSet {
            operationQueue.qualityOfService = qualityOfService
            groupOperation?.groupQoS = qualityOfService
        }
    }

    private(set) lazy var operationQueue: HRTOperationQueue = {
        let queue = HRTOperationQueue()
        queue.name = "\(Self.self).assetsLoadingQueue"
        queue.qualityOfService = self.qualityOfService
        return queue
    }()

    private(set) weak var groupOperation: HRTGroupOperation?

    // MARK: - Init

    public init(_ loadingType: HRTAssetsLoading.Type) {
        loadingTypes = loadingType.allAssetsLoadingDependencies + [loadingType]
    }

    // MARK: - Functionality

    /// Load all associated assets.
    ///
    /// - Returns: A progress object tracking the loading.
    @discardableResult
    public func load(_ completion: HRTSimpleResultBlock? = nil) -> Progress {
        // Set a new progress instance to track loading operations. There is always at least one
        // (the one that initialized this loader).
        let progress = Progress(totalUnitCount: Int64(loadingTypes.count))
        self.progress = progress

        // Create all load operations.
        let loadOperations = loadingTypes.map { HRTLoadAssetsOperation(loadingType: $0) }
        loadOperations.forEach { progress.addChild($0.progress, withPendingUnitCount: 1) }

        // Group load operations into one operation.
        let groupOperation = HRTGroupOperation(loadOperations, groupQoS: qualityOfService)
        groupOperation.addSubscriber(HRTBlockSubscriber { operation, errors in
            // Check if the group operation or any load operation has been cancelled. (When a load
            // operation is cancelled, an error is generated and collected by the group operation.)
            if !operation.isCancelled && errors.isEmpty {
                completion?(.success)
            } else {
                completion?(.failure)
            }
        })
        self.groupOperation = groupOperation

        operationQueue.addOperation(groupOperation)

        return progress
    }

    /// Cancel loading of assets.
    public func cancel() {
        operationQueue.cancelAllOperations()
    }

}
