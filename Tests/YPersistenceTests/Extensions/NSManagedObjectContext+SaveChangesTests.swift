//
//  NSManagedObjectContext+SaveChangesTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
import CoreData
@testable import YPersistence

final class NSManagedObjectContextSaveChangesTests: PersistenceManagerBaseTests {
    func testSaveChangesAndWait() throws {
        try confirmEmpty()

        // insert 2 records
        let context = sut.workerContext
        insertGroceryProduct(.blackberry, context: context)
        insertGroceryProduct(.mango, context: context)

        try context.saveChangesAndWait()

        // Then it should 2 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 2)
    }

    func testSaveChanges() throws {
        try confirmEmpty()

        // insert 2 records
        let context = sut.workerContext
        insertGroceryProduct(.blackberry, context: context)
        insertGroceryProduct(.mango, context: context)

        let expectation = self.expectation(description: "save")
        context.saveChanges { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        // Give save 15 seconds to complete
        wait(for: [expectation], timeout: 15)

        // Then it should 2 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 2)
    }

    func testSaveChangesAndWaitParentContext() throws {
        try confirmEmpty()

        // insert 2 records
        let context = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        context.parent = sut.contextForThread()

        insertGroceryProduct(.blackberry, context: context)
        insertGroceryProduct(.mango, context: context)

        try context.saveChangesAndWait()

        // Then it should 2 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 2)
    }

    func testSaveChangesParentContext() throws {
        try confirmEmpty()

        // insert 2 records
        let context = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        context.parent = sut.contextForThread()

        insertGroceryProduct(.blackberry, context: context)
        insertGroceryProduct(.mango, context: context)

        let expectation = self.expectation(description: "save")
        context.saveChanges { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        // Give save 15 seconds to complete
        wait(for: [expectation], timeout: 15)

        // Then it should 2 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 2)
    }

    func testSaveChangesError() throws {
        try confirmEmpty()

        // insert 2 records
        let context = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        context.parent = sut.contextForThread()

        // declare a managed record, but don't populate it
        // (uid, name, points cannot be nil)
        context.performAndWait {
            let record = ManagedGroceryProduct(managedObjectContext: context)
            guard record != nil else {
                XCTFail("Record was not created")
                return
            }
            XCTAssert(context.hasChanges)
        }

        let expectation = self.expectation(description: "save")
        context.saveChanges { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        // Give save 15 seconds to complete
        wait(for: [expectation], timeout: 15)
        
        // Then it should 0 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }

    func testNoopSync() throws {
        try confirmEmpty()

        let context = sut.workerContext
        try context.saveChangesAndWait()

        // Then it should no records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }

    func testNoopAsync() throws {
        try confirmEmpty()

        let context = sut.workerContext
        try context.saveChangesAndWait()

        let expectation = self.expectation(description: "save")
        context.saveChanges { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        // Give save 15 seconds to complete
        wait(for: [expectation], timeout: 15)
        
        // Then it should no records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }
}
