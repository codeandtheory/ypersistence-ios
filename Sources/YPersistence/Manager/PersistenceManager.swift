//
//  PersistenceManager.swift
//  YPersistence
//
//  Created by Mark Pospesel on 10/4/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import CoreData

/// Manages access to a Core Data stack
open class PersistenceManager {
    private static let contextKey = "PersistenceManager_ManagedObjectContext"

    /// Container to encapsulates the Core Data stack.
    public private(set) var container: NSPersistentContainer

    /// Initializes a Persistence Manager. This should be called
    /// on application launch (but please not as a singleton) and
    /// then passed to classes that need it via Dependency Injection.
    /// - Parameters:
    ///   - modelName: Core Data model name
    ///   - mergePolicy: The merge policy to use for each context. Default = `NSErrorMergePolicy`.
    ///   It is the only policy that requires action to correct any potential conflicts.
    public init(modelName: String, mergePolicy: AnyObject = NSErrorMergePolicy, bundle: Bundle = .main) {
        guard let model = NSManagedObjectModel(from: modelName, in: bundle) else {
            preconditionFailure("There must be a valid Core Data model.")
        }

        self.container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        self.mergePolicy = mergePolicy
    }

    /// Core Data model name
    public var modelName: String { container.name }

    /// The merge policy to apply to all contexts
    public let mergePolicy: AnyObject

    /// Returns the main context, suitable for read-only operations.
    /// If you want to add, edit, delete records you should use a worker context.
    /// This method must be called from the main thread.
    public var mainContext: NSManagedObjectContext {
        precondition(Thread.isMainThread, "Not on main thread")
        let context = container.viewContext
        context.mergePolicy = mergePolicy
        return context
    }

    /// Returns a new private queue context, suitable for short-lived add, edit, delete operations
    /// or for reading from a background thread.
    /// This method may be called from any thread.
    public var workerContext: NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = mergePolicy
        return context
    }

    /// Returns a long-lived context appropriate for fetching results appropriate for the current thread.
    /// This method is thread-safe. When called from a background thread, it will use a cached context if available.
    /// Otherwise it will create a worker context and cache it.
    /// Important: if you need a short-lived context to modify some data, just use `workerContext` instead.
    /// - Returns: a context suitable for use on the calling thread to fetch results
    public func contextForThread() -> NSManagedObjectContext {
        // for main thread simply return the main context
        if Thread.isMainThread { return mainContext }

        // for background thread, check for a cached context
        let threadDictionary = Thread.current.threadDictionary

        if let context = threadDictionary[PersistenceManager.contextKey] as? NSManagedObjectContext {
            return context
        }

        // otherwise, create a context, cache it for next time, then return it
        let context = workerContext
        threadDictionary[PersistenceManager.contextKey] = context
        return context
    }

    /// Asynchronously load the persistence store.
    /// The PersistanceManager is not ready to be used until and unless this method is called
    /// and returns `true` in the completion handler.
    /// This method will fail if called more than once.
    /// - Parameter completion: returns `true` if the store was successfully loaded, otherwise `false`.
    /// Callback occurs on the main thread.
    public func load(completion: @escaping (Bool) -> Void) {
        container.persistentStoreDescriptions.forEach { $0.shouldAddStoreAsynchronously = true }
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint("Unresolved error \(error), \(error.localizedDescription)")
            }

            DispatchQueue.executeOnMain { completion(error == nil) }
        }
    }

    /// Delete all stores from Core Data
    /// - Parameter completion: returns `true` if the store was successfully loaded, otherwise `false`
    open func destroy(completion: @escaping (Bool) -> Void) throws {
        let storeCoordinator =
        container.persistentStoreCoordinator
        try storeCoordinator.persistentStores.forEach { store in
            if let url = store.url {
                try storeCoordinator.destroyPersistentStore(
                    at: url,
                    ofType: store.type,
                    options: nil
                )
            }
        }
        container = NSPersistentContainer(name: modelName, managedObjectModel: container.managedObjectModel)
        self.load(completion: completion)
    }
    
    /// Delete entity from Core Data using batch delete.
    /// Warning: see all the caveats about NSBatchDeleteRequest in the Apple documentation:
    /// https://developer.apple.com/documentation/coredata/nsbatchdeleterequest
    /// This will not respect rules or relations. Cascade delete of dependent entities will not occur.
    /// This only works on Core Data stores backed by SQLite (the default).
    /// - Parameters:
    ///   - entity: the entity to be wiped clean
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error executing the batch delete request or the subsequent save.
    open func batchDeleteAll<Record: DataRecord>(
        entity: Record.Type,
        context: NSManagedObjectContext? = nil
    ) throws {
        try self.batchDeleteAll(entityName: entity.entityName, context: context)
    }
    
    /// Delete all records for an entity (database table).
    /// If there are many (thousands) of records, this may take a noticeable amount of time, so
    /// therefore best to perform on a background thread.
    /// - Parameters:
    ///   - entity: the entity to be wiped clean
    ///   - saveEvery: chunk size for saving during large deletes. Default = 500
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error saving the context after the deletion.
    open func manualDeleteAll<Record: DataRecord>(
        entity: Record.Type,
        saveEvery: Int = 500,
        context: NSManagedObjectContext? = nil
    ) throws {
        try manualDeleteAll(entityName: entity.entityName, saveEvery: saveEvery, context: context)
    }

    /// Delete records matching the specified predicate.
    /// - Parameters:
    ///   - entity: the entity to delete from
    ///   - predicate: the predicate used to filter the records. `nil` means delete all records.
    ///   - saveEvery: chunk size for saving during large deletes. Default = 500
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error saving the context after the deletion.
    open func delete<Record: DataRecord>(
        entity: Record.Type,
        predicate: NSPredicate?,
        saveEvery: Int = 500,
        context: NSManagedObjectContext? = nil
    ) throws {
        try delete(entityName: entity.entityName, predicate: predicate, saveEvery: saveEvery, context: context)
    }
}
