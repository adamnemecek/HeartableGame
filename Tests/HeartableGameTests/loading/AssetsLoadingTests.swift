// Copyright © 2019 Heartable LLC. All rights reserved.

import Heartable
@testable import HeartableGame
import XCTest

final class AssetsLoadingTests: XCTestCase {

    // MARK: - Prep

    static let allLoadingTypes: [BaseAssetsLoading.Type] = [
        A.self, B.self, C.self, D.self, E.self, F.self, G.self,
    ]

    class BaseAssetsLoading: HRTAssetsLoading {
        class var shouldLoadAssets: Bool { return true }
        class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [] }
        class var testLoad: HRTBlock? { return nil }
        class func loadAssets(completion: @escaping HRTBlock) {
            testLoad?()
            completion()
        }
        class func unloadAssets() {}
        class func reset() {}
    }

    class A: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }
    }

    class B: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }
    }

    class C: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }
    }

    class D: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }

        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [A.self, B.self] }
    }

    class E: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }

        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [C.self] }
    }

    class F: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }

        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [D.self, E.self] }
    }

    class G: BaseAssetsLoading {
        override class var testLoad: HRTBlock? { return block }
        static var block: HRTBlock?
        override class func reset() { block = nil }

        override class var shouldLoadAssets: Bool { return false }
        override class var assetsLoadingDependencies: [HRTAssetsLoading.Type] { [A.self] }
    }

    // MARK: - Lifecycle

    override func setUp() {
        Self.allLoadingTypes.forEach { $0.reset() }
    }

    // MARK: - Tests

    func testAllAssetsLoadingDependencies() {
        XCTAssert(A.allAssetsLoadingDependencies.isEmpty)
        XCTAssert(F.allAssetsLoadingDependencies.count == 5)
        XCTAssert(G.allAssetsLoadingDependencies.count == 1)
    }

    func testAssetsLoader_success() {
        let expA = expectation(description: "A is loaded")
        let expB = expectation(description: "B is loaded")
        let expC = expectation(description: "C is loaded")
        let expD = expectation(description: "D is loaded")
        let expE = expectation(description: "E is loaded")
        let expF = expectation(description: "F is loaded")

        A.block = { expA.fulfill() }
        B.block = { expB.fulfill() }
        C.block = { expC.fulfill() }
        D.block = { expD.fulfill() }
        E.block = { expE.fulfill() }
        F.block = { expF.fulfill() }

        let expSuccess = expectation(description: "successful loading")
        let expNoFailure = expectation(description: "no loading failures")
        expNoFailure.isInverted = true

        let assetsLoader = HRTAssetsLoader(F.self)
        assetsLoader.load { result in
            switch result {
            case .success:
                XCTAssert(assetsLoader.progress!.fractionCompleted == 1)
                expSuccess.fulfill()
            case .failure:
                expNoFailure.fulfill()
            }
        }

        let exps = [expA, expB, expC, expD, expE, expF, expSuccess, expNoFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testAssetsLoader_skip() {
        let expA = expectation(description: "A is loaded")
        let expNoG = expectation(description: "G is not loaded")
        expNoG.isInverted = true

        A.block = { expA.fulfill() }
        G.block = { expNoG.fulfill() }

        let expSuccess = expectation(description: "successful loading")
        let expNoFailure = expectation(description: "no loading failures")
        expNoFailure.isInverted = true

        let assetsLoader = HRTAssetsLoader(G.self)
        assetsLoader.load { result in
            switch result {
            case .success:
                XCTAssert(assetsLoader.progress!.fractionCompleted == 1)
                expSuccess.fulfill()
            case .failure:
                expNoFailure.fulfill()
            }
        }

        let exps = [expA, expNoG, expSuccess, expNoFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testAssetsLoader_cancelLoader() {
        let expNoSuccess = expectation(description: "no successful loading")
        expNoSuccess.isInverted = true
        let expFailure = expectation(description: "loading failure")

        let assetsLoader = HRTAssetsLoader(E.self)
        C.block = { assetsLoader.cancel() }
        assetsLoader.load { result in
            switch result {
            case .success:
                expNoSuccess.fulfill()
            case .failure:
                expFailure.fulfill()
            }
        }

        let exps = [expNoSuccess, expFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testAssetsLoader_cancelProgress() {
        let expNoC = expectation(description: "C is not loaded.")
        expNoC.isInverted = true
        let expNoE = expectation(description: "E is not loaded.")
        expNoE.isInverted = true

        C.block = { expNoC.fulfill() }
        E.block = { expNoE.fulfill() }

        let expNoSuccess = expectation(description: "no successful loading")
        expNoSuccess.isInverted = true
        let expFailure = expectation(description: "loading failure")

        let assetsLoader = HRTAssetsLoader(E.self)
        assetsLoader.operationQueue.isSuspended = true
        let progress = assetsLoader.load { result in
            switch result {
            case .success:
                expNoSuccess.fulfill()
            case .failure:
                XCTAssert(assetsLoader.progress!.fractionCompleted < 1)
                expFailure.fulfill()
            }
        }

        // Make sure the progress's cancellation handler is not triggered so we can test whether
        // children progress cancellations will result in loading failure.
        progress.cancellationHandler = nil
        progress.cancel()
        assetsLoader.operationQueue.isSuspended = false

        let exps = [expNoC, expNoE, expNoSuccess, expFailure]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

    func testAssetsLoader_raisePriority() {
        let assetsLoader = HRTAssetsLoader(A.self)
        XCTAssertNoThrow(assetsLoader.qualityOfService = .userInitiated)
        XCTAssert(assetsLoader.operationQueue.qualityOfService == .userInitiated)

        let exp1 = expectation(description: "load completes")
        assetsLoader.load { _ in
            XCTAssertNotNil(assetsLoader.groupOperation)
            XCTAssert(assetsLoader.groupOperation!.qualityOfService == .userInitiated)
            exp1.fulfill()
        }

        XCTWaiter.wait(for: [exp1], timeout: 0.5).process {
            XCTAssertNoThrow(assetsLoader.qualityOfService = .background)
            XCTAssert(assetsLoader.operationQueue.qualityOfService == .background)
        }
    }

    func testNestedOperations() {
        let expA = expectation(description: "A is loaded")
        let expB = expectation(description: "B is loaded")
        let expD = expectation(description: "D is loaded")

        A.block = { expA.fulfill() }
        B.block = { expB.fulfill() }
        D.block = { expD.fulfill() }

        let assetsLoader = HRTAssetsLoader(D.self)
        let expOp1 = expectation(description: "Op1 is run")
        let op1 = HRTBlockOperation({ completion in
            assetsLoader.load {
                if $0 == .success {
                    expOp1.fulfill()
                    completion()
                }
            }
        })

        let expOp2 = expectation(description: "Op2 is run")
        let op2 = HRTBlockOperation({ completion in
            XCTAssert(assetsLoader.progress!.fractionCompleted == 1)
            expOp2.fulfill()
            completion()
        })
        op2.addDependency(op1)

        let q1 = HRTOperationQueue()
        q1.addOperation(op2)
        q1.addOperation(op1)

        let exps = [expA, expB, expD, expOp1, expOp2]
        XCTWaiter.wait(for: exps, timeout: 0.5).process()
    }

}
