//
//  PersistenceManager+BulkDeleteTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest

final class PersistenceManagerBulkDeleteTests: PersistenceManagerBaseTests {
    func testBatchDeleteAll() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        try sut.batchDeleteAll(entity: ManagedGroceryProduct.self)

        // But after delete all it should be empty again
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }

    func testManualDeleteAll() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        try sut.manualDeleteAll(entity: ManagedGroceryProduct.self)

        // But after delete all it should be empty again
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }

    func testSaveEvery() throws {
        try confirmEmpty()

        for _ in 0..<10 {
            try insertGroceryProductsWithDuplicates()
        }

        // Then it should have 70 records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 70)

        // Call save after every 25 deletes
        try sut.manualDeleteAll(entity: ManagedGroceryProduct.self, saveEvery: 25)

        // But after delete all it should be empty again
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }
}
