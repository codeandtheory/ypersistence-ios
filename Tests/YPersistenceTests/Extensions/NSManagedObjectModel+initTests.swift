//
//  NSManagedObjectModel+initTests.swift
//  YPersistenceTestHarnessTests
//
//  Created by Karthik K Manoj on 03/06/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
import CoreData
@testable import YPersistence

final class NSManagedObjectModelInitTests: XCTestCase {
    func test_init_succeedsOnValidModel() {
        XCTAssertNotNil(makeSUT(modelName: "YPersistence", bundle: .module))
    }

    func test_init_failsOnInvalidModel() {
        XCTAssertNil(makeSUT(modelName: "YPersistence", bundle: .main)) // wrong bundle
        XCTAssertNil(makeSUT(modelName: "YPersistence ", bundle: .module)) // wrong model name
    }

    private func makeSUT(modelName: String, bundle: Bundle = .main) -> NSManagedObjectModel? {
        NSManagedObjectModel(from: modelName, in: bundle)
    }
}
