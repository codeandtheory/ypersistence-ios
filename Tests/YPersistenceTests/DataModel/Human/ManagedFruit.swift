//
//  ManagedFruits.swift
//  YPersistence
//
//  Created by Sahil Saini on 20/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import YPersistence
import CoreData

@objc(ManagedFruit)
open class ManagedFruit: _ManagedFruit {
    // Custom logic goes here.
}

/// Represents a uniquely identifiable model object.
/// This could be a `struct` or `class`. It just needs some sort of unique identifier.
extension ManagedFruit: CoreModel {
    /// The model object's unique identifier
    public var uid: String { id }
}

/// Represents a uniquely identifiable Core Data record as returned by a fetch request.
/// In most cases this will be an NSManagedObject. The important part is that it be uniquely identifiable.
extension ManagedFruit: SyncRecord {
    /// The entity name (database table name)
    public static var entityName: String { entityName() }

    /// The name of the attribute (database column) that represents the unique identifier field.
    /// For each custom `NSManagedObject` subclass you would override
    /// this to return the name of the attribute to use. Defaults to `"uid"`.
    public static var uidKey: String { ManagedFruitAttributes.id.rawValue }
}

/// Represents a Core Data record that is associated with a model object having the same unique identifier
extension ManagedFruit: ModelRepresentable {
    /// The associated model object for this type of record.
    public typealias ModelType = Fruit
}

/// Represents a Core Data record that can be converted into a model object
extension ManagedFruit: RecordToModel {
    /// Convert the Core Data record into a model object
    public func toModel() -> Fruit {
        Fruit(uid: id, name: name)
    }
}

/// Represents a Core Data record that can be populated from a model object.
extension ManagedFruit: RecordFromModel {
    /// Populate the Core Data record from the provided model object
    public func fromModel(_ model: Fruit) {
        self.id = model.uid
        self.name = model.name
    }
}
