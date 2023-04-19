//
//  SyncRecord.swift
//  YPersistence
//
//  Created by Sahil Saini on 13/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents status of record data, uploaded and deleted
public protocol SyncRecord: DataRecord {
    /// Whether record is uploaded or not
    var isUploaded: Bool { get set }
    /// Whether record is deleted or not
    var wasDeleted: Bool { get set }

    /// Optional sort order
    static var sort: SortInfo? { get }
    /// The name of the attribute (database column) that represents the upload status
    static var isUploadedKey: String { get }
    /// The name of the attribute (database column) that represents the delete status
    static var wasDeletedKey: String { get }
}

/// Default implementation
extension SyncRecord {
    /// Returns `nil` (no sort order)
    public static var sort: SortInfo? { nil }
    /// Returns "isUploaded"
    public static var isUploadedKey: String { Constants.SyncRecord.isUploaded }
    /// Returns "wasDeleted"
    public static var wasDeletedKey: String { Constants.SyncRecord.wasDeleted }
}

enum Constants {
    enum SyncRecord {
        static let isUploaded = "isUploaded"
        static let wasDeleted = "wasDeleted"
    }
}
