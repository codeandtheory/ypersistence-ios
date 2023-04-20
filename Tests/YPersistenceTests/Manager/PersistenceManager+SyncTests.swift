//
//  PersistenceManager+SyncTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 18/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest

final class PersistenceManagerSyncTests: PersistenceManagerBaseTests {
    func test_fetchRecordsToUpload() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        /// Condition -> isUploaded == false
        /// true for Apple and Banana
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpload()
        XCTAssertEqual(allProducts.count, 2)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
        }
    }

    /// Condition -> isUploaded == false && wasDeletedKey == true
    /// true for Banana only
    func test_fetchRecordsToDelete () throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete()
        XCTAssertEqual(allProducts.count, 1)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
            XCTAssertTrue(product.wasDeleted)
        }
    }

    /// Condition -> isUploaded == false && wasDeletedKey == false
    /// true for Apple only
    func test_fetchRecordsToUpdate() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpdate()
        XCTAssertEqual(allProducts.count, 1)
        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
            XCTAssertFalse(product.wasDeleted)
        }
    }

    func test_fetchRecordsToUploadWithContext() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let context = sut.contextForThread()
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpload(context: context)

        for product in allProducts {
            XCTAssertEqual(product.managedObjectContext, context)
        }
    }

    func test_fetchRecordsToDeleteWithContext() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let context = sut.contextForThread()
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete(context: context)
        for product in allProducts {
            XCTAssertEqual(product.managedObjectContext, context)
        }
    }

    func test_fetchRecordsToUpdateWithContext() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let context = sut.contextForThread()
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpdate(context: context)
        for product in allProducts {
            XCTAssertEqual(product.managedObjectContext, context)
        }
    }
}
