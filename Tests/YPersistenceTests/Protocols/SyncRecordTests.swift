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
    var syncRecordSut: SyncRecordTest!
    var syncRecordDefaultSut: SyncRecordDefaultTest!

    override func setUp() {
        super.setUp()
        syncRecordSut = SyncRecordTest()
        syncRecordDefaultSut = SyncRecordDefaultTest()
    }

    override func tearDown() {
        super.tearDown()
        syncRecordSut = nil
        syncRecordDefaultSut = nil
    }

    func test_keysDefaultValues() {
        XCTAssertEqual(SyncRecordDefaultTest.isUploadedKey, Constants.SyncRecord.isUploaded)
        XCTAssertEqual(SyncRecordDefaultTest.wasDeletedKey, Constants.SyncRecord.wasDeleted)
    }

    func test_keysUpdating() {
        XCTAssertEqual(SyncRecordTest.isUploadedKey, "Uploading")
        XCTAssertEqual(SyncRecordTest.wasDeletedKey, "Deleted")
    }

    func test_statusFlags_deliversCorrectResult() {
        XCTAssertFalse(syncRecordSut.wasDeleted)
        XCTAssertFalse(syncRecordSut.isUploaded)

        syncRecordSut.isUploaded = true
        syncRecordSut.wasDeleted = true

        XCTAssertTrue(syncRecordSut.wasDeleted)
        XCTAssertTrue(syncRecordSut.isUploaded)
    }
}

final class SyncRecordTest: NSObject { /* To conform to NSObjectProtocol*/
    var isUploadedTest: Bool = false
    var wasDeletedTest: Bool = false
}

extension SyncRecordTest: SyncRecord {
    var isUploaded: Bool {
        get {
            isUploadedTest
        }
        set(newValue) {
            isUploadedTest = newValue
        }
    }

    var wasDeleted: Bool {
        get {
            wasDeletedTest
        }
        set(newValue) {
            wasDeletedTest = newValue
        }
    }

    static var isUploadedKey: String { "Uploading" }
    static var wasDeletedKey: String { "Deleted" }
}

extension SyncRecordTest { /* DataRecord */
    var uid: String { "456" }

    static var entityName: String { "Car" }

    static var uidKey: String { "cid" }
}

final class SyncRecordDefaultTest: NSObject { /* To conform to NSObjectProtocol*/
    var isUploadedTest: Bool = false
    var wasDeletedTest: Bool = false
}

extension SyncRecordDefaultTest: SyncRecord {
    var isUploaded: Bool {
        get {
            isUploadedTest
        }
        set(newValue) {
            isUploadedTest = newValue
        }
    }

    var wasDeleted: Bool {
        get {
            wasDeletedTest
        }
        set(newValue) {
            wasDeletedTest = newValue
        }
    }

    /* DataRecord */
    var uid: String { "456" }

    static var entityName: String { "Car" }

    static var uidKey: String { "cid" }
}
