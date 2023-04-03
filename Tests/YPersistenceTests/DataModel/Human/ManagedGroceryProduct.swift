import Foundation
import YPersistence

@objc(ManagedGroceryProduct)
open class ManagedGroceryProduct: _ManagedGroceryProduct {
	// Custom logic goes here.
}

/// Represents a uniquely identifiable model object.
/// This could be a `struct` or `class`. It just needs some sort of unique identifier.
extension ManagedGroceryProduct: CoreModel {
    /// The model object's unique identifier
     public var uid: String { id }
}

/// Represents a uniquely identifiable Core Data record as returned by a fetch request.
/// In most cases this will be an NSManagedObject. The important part is that it be uniquely identifiable.
extension ManagedGroceryProduct: DataRecord {
    /// The entity name (database table name)
    public static var entityName: String { entityName() }

    /// The name of the attribute (database column) that represents the unique identifier field.
    /// For each custom `NSManagedObject` subclass you would override
    /// this to return the name of the attribute to use. Defaults to `"uid"`.
    public static var uidKey: String { ManagedGroceryProductAttributes.id.rawValue }
}

/// Represents a Core Data record that is associated with a model object having the same unique identifier
extension ManagedGroceryProduct: ModelRepresentable {
    /// The associated model object for this type of record.
    public typealias ModelType = GroceryProduct
}

/// Represents a Core Data record that can be converted into a model object
extension ManagedGroceryProduct: RecordToModel {
    /// Convert the Core Data record into a model object
    public func toModel() -> GroceryProduct {
        GroceryProduct(uid: id, name: name, points: Int(points), description: details)
    }
}

/// Represents a Core Data record that can be populated from a model object.
extension ManagedGroceryProduct: RecordFromModel {
    /// Populate the Core Data record from the provided model object
    public func fromModel(_ model: GroceryProduct) {
        self.id = model.uid
        self.name = model.name
        self.points = Int32(model.points)
        self.details = model.description
    }
}
