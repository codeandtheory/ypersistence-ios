// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedFruits.swift instead.

import Foundation
import CoreData

// swiftlint: disable type_name

public enum ManagedFruitAttributes: String {
    case id
    case name
    case isUploaded
    case wasDeleted
}

open class _ManagedFruit: NSManagedObject {
    // MARK: - Class methods

    open class func entityName () -> String { "ManagedFruit" }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<ManagedFruit> {
        NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _ManagedFruit.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var id: String!

    @NSManaged open
    var name: String!

    @NSManaged open
    var isUploaded: Bool

    @NSManaged open
    var wasDeleted: Bool
}
// swiftlint: enable type_name
