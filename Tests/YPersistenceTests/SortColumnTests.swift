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
        let sut = makeSut()
        XCTAssertTrue(sut.ascending)
    }

    func test_descriptorKeyOrder_isCorrect() {
        let expectedKey = "Mango"
        let sut = makeSut(key: expectedKey, ascending: false)

        XCTAssertEqual(sut.descriptor.key, expectedKey)
        XCTAssertFalse(sut.descriptor.ascending)
    }
}

extension SortColumnTests {
    func makeSut(key: String = "FruitsType", ascending: Bool = true) -> SortColumn {
        SortColumn(key: key, ascending: ascending)
    }
}
