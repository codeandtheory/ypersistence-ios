//
//  DataRecord.swift
//  YPersistence
//
//  Created by Sumit Goswami on 29/10/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

/// Any value type that can represent a unique identifier for a data record (String, Int, UInt, UUID, etc.)
public typealias UniqueIdentifier = CustomStringConvertible & Comparable

/// Represents a uniquely identifiable Core Data record as returned by a fetch request.
/// In most cases this will be an NSManagedObject. The important part is that it be uniquely identifiable.
public protocol DataRecord: NSFetchRequestResult, CoreModel {
    /// The entity name (database table name)
    static var entityName: String { get }

    /// The name of the attribute (database column) that represents the unique identifier field.
    /// For each custom `NSManagedObject` subclass you would override
    /// this to return the name of the attribute to use. Defaults to `"uid"`.
    static var uidKey: String { get }
}

/// Default implementation
public extension DataRecord {
    /// Returns "uid" by default
    static var uidKey: String { "uid" }
}
