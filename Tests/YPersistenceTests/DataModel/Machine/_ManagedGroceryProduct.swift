// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ManagedGroceryProduct.swift instead.

import Foundation
import CoreData

// swiftlint: disable type_name

public enum ManagedGroceryProductAttributes: String {
    case details
    case id
    case name
    case points
}

open class _ManagedGroceryProduct: NSManagedObject {
    // MARK: - Class methods

    open class func entityName () -> String { "ManagedGroceryProduct" }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<ManagedGroceryProduct> {
        NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _ManagedGroceryProduct.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var details: String?

    @NSManaged open
    var id: String!

    @NSManaged open
    var name: String!

    @NSManaged open
    var points: Int32

    // MARK: - Relationships
}
// swiftlint: enable type_name
