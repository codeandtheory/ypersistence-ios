//
//  PersistenceManager+BulkDelete.swift
//  YPersistence
//
//  Created by Sumit Goswami on 12/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    /// Delete all records for an entity (database table).
    /// If there are many (thousands) of records, this may take a noticeable amount of time, so
    /// therefore best to perform on a background thread.
    /// - Parameters:
    ///   - entityName: the name of entity to be wiped clean.
    ///   - saveEvery: chunk size for saving during large deletes. Default = 500
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error saving the context after the deletion.
    @objc open func manualDeleteAll(
        entityName: String,
        saveEvery: Int = 500,
        context: NSManagedObjectContext? = nil
    ) throws {
        try delete(entityName: entityName, predicate: nil, saveEvery: saveEvery, context: context)
    }

    /// Delete entity from Core Data using batch delete.
    /// Warning: see all the caveats about NSBatchDeleteRequest in the Apple documentation:
    /// https://developer.apple.com/documentation/coredata/nsbatchdeleterequest
    /// This will not respect rules or relations. Cascade delete of dependent entities will not occur.
    /// This only works on Core Data stores backed by SQLite (the default).
    /// - Parameters:
    ///   - entityName: the name of entity to be wiped clean.
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error executing the batch delete request or the subsequent save.
    @objc open func batchDeleteAll(
        entityName: String,
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Configure the request to return the IDs of the objects it deletes.
        deleteRequest.resultType = .resultTypeObjectIDs
        
        var caught: Error?
        
        context.performAndWait {
            do {
                // Execute the request.
                let deleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
                
                // Extract the IDs of the deleted managed objectss from the request's result.
                if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
                    // we would need to include any background thread contexts here
                    let allContexts = [container.viewContext]
                    
                    // Merge the deletions into the app's managed object context.
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                        into: allContexts
                    )
                }
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
    }
}
