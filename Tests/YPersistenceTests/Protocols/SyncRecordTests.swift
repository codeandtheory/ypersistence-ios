//
//  SyncRecordTests.swift
//  YPersistence
//
//  Created by Sahil Saini on 13/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class SyncRecordTests: XCTestCase {
    func test_keysDefaultValues() {
        XCTAssertEqual(SyncRecordDefaultTest.isUploadedKey, Constants.SyncRecord.isUploaded)
        XCTAssertEqual(SyncRecordDefaultTest.wasDeletedKey, Constants.SyncRecord.wasDeleted)
    }

    func test_keysUpdating() {
        XCTAssertEqual(SyncRecordTest.isUploadedKey, "Uploading")
        XCTAssertEqual(SyncRecordTest.wasDeletedKey, "Deleted")
    }

    func test_statusFlags_deliversCorrectResult() {
        let sut = SyncRecordTest()
        XCTAssertFalse(sut.wasDeleted)
        XCTAssertFalse(sut.isUploaded)

        sut.isUploaded = true
        sut.wasDeleted = true

        XCTAssertTrue(sut.wasDeleted)
        XCTAssertTrue(sut.isUploaded)
    }

    func test_defaultSort_deliversNil() {
        // Default should be nil
        XCTAssertNil(SyncRecordDefaultTest.sort)
    }
    
    func test_sort_deliversCorrectResult() {
        let keys = ["Convenstional", "Digital"]
        let columns = [
            SortColumn(key: keys[0], ascending: SyncRecordTest.ascending),
            SortColumn(key: keys[1], ascending: !SyncRecordTest.ascending)
        ]

        let expectedSortInfo = SortInfo(columns: columns)

        XCTAssertEqual(SyncRecordTest.sort, expectedSortInfo)
    }
}

final class SyncRecordTest: NSObject { /* To conform to NSObjectProtocol*/
    static let ascending = Bool.random()
    static var columns: [SortColumn] {
        [
            SortColumn(key: "Convenstional", ascending: SyncRecordTest.ascending),
            SortColumn(key: "Digital", ascending: !SyncRecordTest.ascending)
        ]
    }
    /* SyncRecord */
    var isUploaded: Bool = false
    var wasDeleted: Bool = false
    static var sort: SortInfo? = SortInfo(columns: columns)

    static var isUploadedKey: String { "Uploading" }
    static var wasDeletedKey: String { "Deleted" }
}

extension SyncRecordTest: SyncRecord {
    /* DataRecord */
    var uid: String { "Rose" }

    static var entityName: String {
        "Black Diamond"
    }
}

final class SyncRecordDefaultTest: NSObject { /* To conform to NSObjectProtocol*/
    var isUploaded: Bool = false
    var wasDeleted: Bool = false
}

extension SyncRecordDefaultTest: SyncRecord {
    /* DataRecord */
    var uid: String { "Mango" }

    static var entityName: String {
        "Summer"
    }
}
