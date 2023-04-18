//
//  SortInfoTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 17/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import YPersistence

final class SortInfoTests: XCTestCase {
    func test_descriptors_deliversCorrectValues() {
        let keys = ["Blood Diamond", "Mango"]
        let ascending = Bool.random()
        let columnsAttributes = [(keys[0], ascending), (keys[1], !ascending)]

        let sut = makeSUT(attributes: columnsAttributes)
        let expectedDescriptors = [
            NSSortDescriptor(key: keys[0], ascending: ascending),
            NSSortDescriptor(key: keys[1], ascending: !ascending)
        ]

        XCTAssertEqual(sut.descriptors, expectedDescriptors)
    }
}

extension SortInfoTests {
    func makeSUT(attributes: [(String, Bool)]) -> SortInfo {
        let columns: [SortColumn] = attributes.map { SortColumn(key: $0.0, ascending: $0.1) }
        return SortInfo(columns: columns)
    }
}
