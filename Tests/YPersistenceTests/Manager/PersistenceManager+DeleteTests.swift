//
//  PersistenceManager+DeleteTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
import CoreData
@testable import YPersistence

final class PersistenceManagerDeleteTests: PersistenceManagerBaseTests {
    func testDeleteByUids() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        // Given we delete some uids that are not in the database
        try sut.delete(entity: ManagedGroceryProduct.self, uids: ["abc", "xyz", "123"])

        // But after delete we should still have 4 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 4)

        // Then if we delete uids that _are_ in the database
        try sut.delete(
            entity: ManagedGroceryProduct.self,
            uids: [GroceryProduct.blackberry.uid, GroceryProduct.mango.uid]
        )

        // After delete we should have 2 records
        let final = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(final.count, 2)
    }

    func testDeleteByUid() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        // Then if we delete uids that _are_ in the database
        try sut.delete(entity: ManagedGroceryProduct.self, uid: GroceryProduct.durian.uid)

        // After delete we should have 3 records
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 3)
    }

    func testDeleteModel() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        // Given we delete 1 model
        try sut.deleteModel(entity: ManagedGroceryProduct.self, model: .mango)

        // After delete we should have 3 records
        let final = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(final.count, 3)
    }

    func testDeleteModels() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        // Given we delete 3 models
        try sut.deleteModels(entity: ManagedGroceryProduct.self, models: [.banana, .durian, .blackberry])

        // After delete we should have 1 record
        let final = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(final.count, 1)
    }

    func testDeleteDuplicates() throws {
        try confirmEmpty()

        try insertGroceryProductsWithDuplicates()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 7)

        // Given we delete the 2 models that have duplicates (5 records total)
        try sut.deleteModels(entity: ManagedGroceryProduct.self, models: [.banana, .mango])

        // After delete we should have only 2 records
        let final = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(final.count, 2)
    }

    func testDeleteByPredicate() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        // Given we delete 2 records
        let uids = [GroceryProduct.banana, GroceryProduct.blackberry].map({ $0.uid })
        let predicate = NSPredicate(format: "\(ManagedGroceryProduct.uidKey) in %@", uids)
        try sut.delete(entity: ManagedGroceryProduct.self, predicate: predicate)

        // After delete we should have 2 records
        let final = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(final.count, 2)
    }
}
