//
//  SortColumnTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 13/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class SortColumnTests: XCTestCase {
    func test_defaultAscendingOrder_isTrue() {
        let sut = makeSUT()
        XCTAssertTrue(sut.ascending)
    }

    func test_descriptor_deliversCorrectValues() {
        let key = "Mango"
        let ascending = Bool.random()
        let sut = makeSUT(key: key, ascending: ascending)
        let expected = NSSortDescriptor(key: key, ascending: ascending)
        XCTAssertEqual(sut.descriptor, expected)
    }
}

extension SortColumnTests {
    func makeSUT(key: String = "FruitsType", ascending: Bool = true) -> SortColumn {
        SortColumn(key: key, ascending: ascending)
    }
}
