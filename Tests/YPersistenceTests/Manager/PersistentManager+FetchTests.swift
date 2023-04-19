//
//  PersistentManager+FetchTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class PersistentManagerFetchTests: PersistenceManagerBaseTests {
    func testFetchAll() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have records
        let allProducts = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(allProducts.count, 4)
    }

    func testFetchModels() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have 2 records with the following uids
        let uids = ["1", "3", "abad1dea"] // only 1 and 3 exist in the store
        let someProducts = try sut.fetchModels(entity: ManagedGroceryProduct.self, uids: uids)
        XCTAssertEqual(someProducts.count, 2)
    }

    func testFetchModel() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then it should have a record for Durian (uid = 1)
        let durian = try sut.fetchModel(entity: ManagedGroceryProduct.self, uid: "1")
        XCTAssertNotNil(durian)
    }

    func testSort() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        // Then we should be able to fetch records sorted by name
        let allRecords: [ManagedGroceryProduct] = try sut.fetchRecords(
            predicate: nil,
            sortDescriptors: [
                NSSortDescriptor(key: ManagedGroceryProductAttributes.name.rawValue, ascending: true)
            ]
        )

        XCTAssertEqual(allRecords.count, 4)

        // We should be able to convert records to products
        let allProducts = allRecords.compactMap({ $0.toModel() })
        XCTAssertEqual(allProducts.count, 4)

        // and those products should be sorted alphabetically by name
        XCTAssertEqual(allProducts[0], .banana)
        XCTAssertEqual(allProducts[1], .blackberry)
        XCTAssertEqual(allProducts[2], .durian)
        XCTAssertEqual(allProducts[3], .mango)
    }

    func test_fetchRecords_deliversCorrectResults() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        let allRecords: [ManagedGroceryProduct] = try sut.fetchRecords(context: nil)

        XCTAssertEqual(allRecords.count, 4)
    }

    func test_fetchRecordsWithContext_deliversCorrectResults() throws {
        try confirmEmpty()
        try insertGroceryProducts()

        let allRecords: [ManagedGroceryProduct] = try sut.fetchRecords(
            context: sut.workerContext
        )

        XCTAssertEqual(allRecords.count, 4)
    }
}
