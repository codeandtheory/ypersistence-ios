//
//  PersistentManager+ClearTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest

final class PersistentManagerClearTests: PersistenceManagerBaseTests {
    func testClear() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        try sut.clear()

        // But after clear it should be empty again
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }

    func testDestroy() throws {
        try confirmEmpty()

        try insertGroceryProducts()

        // Then it should have records
        let before = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(before.count, 4)

        var result: Bool?
        let expectation = self.expectation(description: "Destroy store")
        try sut.destroy { success in
            result = success
            expectation.fulfill()
        }

        // Give destroy 15 seconds to complete
        wait(for: [expectation], timeout: 15)

        XCTAssertTrue(result ?? false)

        // But after destroy it should be empty again
        let after = try sut.fetchModels(entity: ManagedGroceryProduct.self)
        XCTAssertEqual(after.count, 0)
    }
}
