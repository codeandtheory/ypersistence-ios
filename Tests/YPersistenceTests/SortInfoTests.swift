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
        let key = "Blood Diamond"
        let ascending = Bool.random()
        let sortColumns = [SortColumn(key: key, ascending: ascending)]
        let sut = makeSUT(sortColumns: sortColumns)
        let expectedDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        XCTAssertEqual(sut.descriptors, expectedDescriptors)
    }
}

extension SortInfoTests {
    func makeSUT(sortColumns: [SortColumn]) -> SortInfo {
        SortInfo(columns: sortColumns)
    }
}
