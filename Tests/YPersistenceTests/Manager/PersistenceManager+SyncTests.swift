//
//  PersistenceManager+SyncTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 18/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest

final class PersistenceManagerSyncTests: PersistenceManagerBaseTests {
    func test_defaultRecords_areMarkedForUpload() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        // Condition -> isUploaded == false
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpload()
        XCTAssertEqual(allProducts.count, 4)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
        }
    }

    func test_defaultRecords_areMarkedForUpdate() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        // Condition -> isUploaded == false && wasDeleted == false
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpdate()
        XCTAssertEqual(allProducts.count, 4)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
        }
    }

    func test_defaultRecords_areNotMarkedForDeletion() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        // Condition -> isUploaded == false && wasDeleted == true
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete()
        XCTAssertEqual(allProducts.count, 0)
    }

    func test_fetchRecordsToUpload_deliversMarkedForUploadRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()
        try uploadFruit(.apple)
        try deleteFruit(.banana)

        // Condition -> isUploaded == false
        // true for .apple
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpload()
        XCTAssertEqual(allProducts.count, 3)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
        }
    }

    func test_fetchRecordsToUpdate_deliversMarkedForUpdateRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()
        try uploadFruit(.apple)
        try deleteFruit(.banana)

        // Condition -> isUploaded == false && wasDeleted == false
        // true for .apple and .banana
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToUpdate()
        XCTAssertEqual(allProducts.count, 2)
        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
            XCTAssertFalse(product.wasDeleted)
        }
    }

    func test_fetchRecordsToDelete_deliversMarkedForDeleteRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()
        try uploadFruit(.apple)
        try deleteFruit(.banana)

        // Condition -> isUploaded == false && wasDeleted == true
        // true for .banana
        let allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete()
        XCTAssertEqual(allProducts.count, 1)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
            XCTAssertTrue(product.wasDeleted)
        }
    }

    func test_markRecordAsUploaded_deliversMarkedForUploadedRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        var allProducts: [ManagedFruit] = try sut.fetchRecordsToUpload()
        XCTAssertEqual(allProducts.count, 4)

        let uids = ["1", "2"]
        try sut.markRecordsAsUploaded(enity: ManagedFruit.self, uids: uids)

        allProducts = try sut.fetchRecordsToUpload()
        XCTAssertEqual(allProducts.count, 2) // with uid 1 and 2

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
        }
    }
    
    func test_markRecordAsDelete_deliversMarkedForDeleteRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        let uids = ["1", "2", "x"]
        try sut.markRecordsAsDeleted(enity: ManagedFruit.self, uids: uids)

        let allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete()
        XCTAssertEqual(allProducts.count, 2)

        for product in allProducts {
            XCTAssertTrue(product.wasDeleted)
        }
    }

    func test_markRecordsDelete_deliversAllMarkedForDeleteRecords() throws {
        try confirmFruitsEmpty()
        try insertFruits()

        var allProducts: [ManagedFruit] = try sut.fetchRecordsToDelete()
        // No fruits are marked for deletion
        XCTAssertEqual(allProducts.count, 0)

        try sut.markAllRecordsAsDeleted(enity: ManagedFruit.self)

        allProducts = try sut.fetchRecordsToDelete()
        XCTAssertEqual(allProducts.count, 4)

        for product in allProducts {
            XCTAssertFalse(product.isUploaded)
            XCTAssertTrue(product.wasDeleted)
        }
    }
}
