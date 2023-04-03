//
//  DataRecordTests.swift
//  YPersistenceTestHarnessTests
//
//  Created by Sumit Goswami on 29/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class DataRecordTests: XCTestCase {
    var bookSut: BookRecord!
    var carSut: CarRecord!

    override func setUp() {
        super.setUp()
        bookSut = BookRecord()
        carSut = CarRecord()
    }

    override func tearDown() {
        super.tearDown()
        bookSut = nil
    }

    func testUid() {
        XCTAssertEqual(bookSut.uid, 123)
        XCTAssertEqual(carSut.uid, "456")
    }

    func testUidKey() {
        XCTAssertEqual(BookRecord.uidKey, "uid")
        XCTAssertEqual(CarRecord.uidKey, "cid")
    }

    func testEntityName() {
        XCTAssertFalse(BookRecord.entityName.isEmpty)
        XCTAssertFalse(CarRecord.entityName.isEmpty)
    }
}

final class BookRecord: NSObject { /* To conform to NSObjectProtocol*/ }

extension BookRecord: DataRecord {
    var uid: Int { 123 }

    static var entityName: String { "Book" }
}

final class CarRecord: NSObject { /* To conform to NSObjectProtocol*/ }

extension CarRecord: DataRecord {
    var uid: String { "456" }

    static var entityName: String { "Car" }

    static var uidKey: String { "cid" }
}
