//
//  PersistenceMnager+FetchRecordsTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 18/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class PersistenceMnagerFetchRecordsTests: PersistenceManagerBaseTests {
    func test_fetchRecords_deliversCorrectResults() throws {
        let sut = makeSUT()

        try confirmEmpty()
        try insertGroceryProducts()

        let allRecords: [ManagedGroceryProduct] = try sut.fetchRecords(
            predicate: nil,
            sortDescriptors: nil,
            context: nil
        )

        XCTAssertEqual(allRecords.count, 4)
    }

    func test_fetchRecordsWithContext_deliversCorrectResults() throws {
        let sut = makeSUT()

        try confirmEmpty()
        try insertGroceryProducts()

        let context = sut.container.newBackgroundContext()

        let allRecords: [ManagedGroceryProduct] = try sut.fetchRecords(
            predicate: nil,
            sortDescriptors: nil,
            context: context
        )

        XCTAssertEqual(allRecords.count, 4)
    }
}

extension PersistenceMnagerFetchRecordsTests {
    func makeSUT() -> PersistenceManager {
        let manager = makePersistenceManager(modelName: "YPersistence")
        let exp = expectation(description: "Wait for store deletion.")

        manager.load { _ in
            do {
                // begin each test with an empty store
                try manager.destroy { _ in
                    exp.fulfill()
                }
            } catch {
                XCTFail("Fail to destroy")
            }
        }
        wait(for: [exp], timeout: 15)
        return manager
    }
}
