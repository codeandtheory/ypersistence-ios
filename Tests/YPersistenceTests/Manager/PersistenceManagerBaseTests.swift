//
//  PersistenceManagerBaseTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
import CoreData
@testable import YPersistence

open class PersistenceManagerBaseTests: XCTestCase {
    var sut: PersistenceManager!

    open override func setUpWithError() throws {
        try super.setUpWithError()
        let manager = makePersistenceManager(modelName: "YPersistence")
        let exp = expectation(description: "Wait for store deletion.")
        
        var caught: Error?
        manager.load { _ in
            do {
                // begin each test with an empty store
                try manager.destroy { _ in
                    exp.fulfill()
                }
            } catch {
                caught = error
            }
        }

        if let error = caught { throw error }
        
        wait(for: [exp], timeout: 15)
        sut = manager
    }

    open override func tearDown() {
        super.tearDown()
        sut = nil
    }

    // MARK: - Grocery products

    func confirmEmpty() throws {
        // Database should start empty
        let initial = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(initial.count, 0)
    }

    func insertGroceryProducts() throws {
        try insertGroceryProducts([.durian, .banana, .mango, .blackberry])
    }

    func insertGroceryProductsWithDuplicates() throws {
        try insertGroceryProducts([.durian, .banana, .banana, .banana, .mango, .mango, .blackberry])
    }

    func insertGroceryProducts(_ products: [GroceryProduct]) throws {
        let context = sut.contextForThread()
        products.forEach {
            insertGroceryProduct($0, context: context)
        }
        try context.saveChangesAndWait()
    }

    func insertGroceryProduct(_ product: GroceryProduct, context: NSManagedObjectContext) {
        context.performAndWait {
            guard let record = ManagedGroceryProduct(managedObjectContext: context) else { return }
            record.fromModel(product)
        }
    }

    // MARK: - Fruits
    
    func confirmFruitsEmpty() throws {
        // Database should start empty
        let initial = try sut.fetchModels(entity: ManagedFruit.self)
        XCTAssertEqual(initial.count, 0)
    }

    func insertFruits() throws {
        try insertFruits([.grapes, .banana, .mango, .apple])
    }

    func insertFruits(_ products: [Fruit]) throws {
        let context = sut.contextForThread()
        products.forEach {
            insertFruit($0, context: context)
        }
        try context.saveChangesAndWait()
    }

    func insertFruit(_ product: Fruit, context: NSManagedObjectContext) {
        context.performAndWait {
            guard let record = ManagedFruit(managedObjectContext: context) else { return }
            record.fromModel(product)
        }
    }

    func makePersistenceManager(modelName: String, mergePolicy: AnyObject = NSErrorMergePolicy) -> PersistenceManager {
        PersistenceManager(modelName: modelName, mergePolicy: mergePolicy, bundle: .module)
    }
}
