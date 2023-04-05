//
//  ModelRepresentable.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a Core Data record that is associated with a model object having the same unique identifier
public protocol ModelRepresentable: DataRecord {
    /// The associated model object for this type of record.
    /// For example you might have a CustomerJSONObject that can be used to populate
    /// your ManagedCustomer NSManagedObject subclass.
    associatedtype ModelType: CoreModel

    /// The record's unique identifier
    var uid: ModelType.UidType { get }
}
