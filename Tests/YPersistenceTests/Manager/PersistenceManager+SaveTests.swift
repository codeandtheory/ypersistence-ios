//
//  PersistenceManager+SaveTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest

final class PersistenceManagerSaveTests: PersistenceManagerBaseTests {
    func testSaveWithoutOverwrite() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have 4 records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        let newProducts = [
            GroceryProduct(uid: "5", name: "Strawberry", points: 50, description: "Compound fruit"),
            GroceryProduct(uid: "6", name: "Açaí", points: 1000, description: "Rainforest fruit")
            ]

        try sut.save(entity: ManagedGroceryProduct.self, models: newProducts, shouldOverwrite: false)

        // Then it should have 6 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 6)
    }

    func testSaveWithPartialOverwrite() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have 4 records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        let newProducts = [
            GroceryProduct(uid: "5", name: "Strawberry", points: 50, description: "Compound fruit"),
            .blackberry // already in db
            ]

        try sut.save(entity: ManagedGroceryProduct.self, models: newProducts, shouldOverwrite: false)

        // Then it should have 5 records (1 update, 1 insert)
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 5)
    }

    func testDuplicateRemoval() throws {
        try confirmEmpty()
        try insertGroceryProductsWithDuplicates()

        // Then it should have 7 records (4 unique + 3 duplicates)
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 7)

        let newProducts: [GroceryProduct] = [
            .banana, // in db 3x
            .mango   // in db 2x
            ]

        try sut.save(entity: ManagedGroceryProduct.self, models: newProducts, shouldOverwrite: false)

        // Then it should have 4 records (duplicates removed)
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 4)
    }

    func testSaveWithOverwrite() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have 4 records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        let newProducts = [
            GroceryProduct(uid: "5", name: "Strawberry", points: 50, description: "Compound fruit"),
            GroceryProduct(uid: "6", name: "Açaí", points: 1000, description: "Rainforest fruit")
            ]

        try sut.save(entity: ManagedGroceryProduct.self, models: newProducts, shouldOverwrite: true)

        // Then it should have 2 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 2)
    }

    func testSaveNoop() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have 4 records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        let newProducts: [GroceryProduct] = []

        try sut.save(entity: ManagedGroceryProduct.self, models: newProducts, shouldOverwrite: false)

        // Then it should still have 4 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 4)
    }
}
