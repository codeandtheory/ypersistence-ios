//
//  PersistenceManagerTests.swift
//  YPersistenceTestHarnessTests
//
//  Created by Mark Pospesel on 10/4/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
import CoreData
@testable import YPersistence

final class PersistenceManagerTests: PersistenceManagerBaseTests {
    func testInit() {
        XCTAssertNotNil(sut)
    }

    func testMainContext() {
        let context = sut.mainContext
        XCTAssertNotNil(context)
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType)
    }

    func testWorkerContext() {
        let context = sut.workerContext
        XCTAssertNotNil(context)
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType)
    }

    func testModelName() {
        XCTAssertEqual(sut.modelName, "YPersistence")
        XCTAssertEqual(sut.container.name, "YPersistence")
    }

    func testMergePolicy() {
        let mergePolicy = MockMergePolicy()
        let store =  makePersistenceManager(modelName: "YPersistence", mergePolicy: mergePolicy)

        var result: Bool?
        let expectation = self.expectation(description: "Initialize store")
        store.load { success in
            // It should return on the main thread
            XCTAssert(Thread.isMainThread)
            result = success
            expectation.fulfill()
        }

        // Give load 15 seconds to complete
        wait(for: [expectation], timeout: 15)

        XCTAssertTrue(result ?? false)

        let context1 = store.mainContext
        let context2 = store.workerContext

        // The merge policy should be passed to the contexts
        XCTAssertEqual(context1.mergePolicy as? MockMergePolicy, mergePolicy)
        context2.performAndWait {
            XCTAssertEqual(context2.mergePolicy as? MockMergePolicy, mergePolicy)
        }
    }

    func testLoadTwice() {
        var result: Bool?
        let expectation = self.expectation(description: "Initialize store")

        // Given a store that we try to load twice
        sut.load { success in
            // It should return on the main thread
            XCTAssert(Thread.isMainThread)
            result = success
            expectation.fulfill()
        }

        // Give initializeStore 15 seconds to complete
        let output = XCTWaiter.wait(for: [expectation], timeout: 15)

        // We expect load to fail (Can't open the same store twice)
        XCTAssertEqual(output, .completed)
        XCTAssertFalse(result ?? true)
    }

    func testContextForThread() {
        let context1 = sut.contextForThread()
        var context2: NSManagedObjectContext?
        var context3: NSManagedObjectContext?
        var context4: NSManagedObjectContext?

        let expectation1 = self.expectation(description: "Context for Thread (userInitiated)")
        let expectation2 = self.expectation(description: "Context for Thread (background)")

        DispatchQueue.global(qos: .userInitiated).async {
            context2 = self.sut.contextForThread()
            context3 = self.sut.contextForThread()

            expectation1.fulfill()
        }

        DispatchQueue.global(qos: .background).async {
            context4 = self.sut.contextForThread()

            expectation2.fulfill()
        }

        // wait for 15 seconds
        wait(for: [expectation1, expectation2], timeout: 15)

        // we expect context1 to be the main context
        XCTAssertEqual(context1, sut.mainContext)

        // we expect context2 to be a worker context
        XCTAssertNotEqual(context1, context2)
        XCTAssertEqual(context2?.concurrencyType, .privateQueueConcurrencyType)
        // we expect context2 to be the same as context 3 (due to caching)
        XCTAssertEqual(context2, context3)

        // we expect context4 to be a worker context
        XCTAssertEqual(context4?.concurrencyType, .privateQueueConcurrencyType)
        XCTAssertNotEqual(context1, context4)
    }

    func testLoadFromBackgroundThread() {
        let store = makePersistenceManager(modelName: "YPersistence")

        var result: Bool?
        let expectation = self.expectation(description: "Initialize store")

        // Given we call load from a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            store.load { success in
                // It should return on the main thread
                XCTAssert(Thread.isMainThread)
                result = success
                expectation.fulfill()
            }
        }

        // and we allow load 15 seconds to complete
        wait(for: [expectation], timeout: 15)

        // Load should succeed
        XCTAssertTrue(result ?? false)

        // And we should be able to access our contexts
        XCTAssertNotNil(store.mainContext)
        XCTAssertNotNil(store.workerContext)
    }
}

final class MockMergePolicy: NSObject { }
