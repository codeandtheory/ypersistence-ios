//
//  PersistenceManager+Save.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    /// Converts an array of models to Core Data records and synchronously saves them.
    /// Typical use case for this method would be to save the results of a network request, and
    /// in that case should be called from a non-blocking thread.
    /// - Parameters:
    ///   - entity: Core Data entity to save to
    ///   - models: Array of models that will be converted into Core Data records and saved.
    ///   - shouldOverwrite: If `true` all existing records for this entity will be deleted
    ///   and new records matching `models` will be inserted.
    ///   Use `true` for example on pull-to-refresh, when fetching the 1st page of results,
    ///   or whenever you need to account for remote deletes.
    ///   If `false` no local records will be deleted, any existing matching records will be updated,
    ///   any local duplicates will be removed, and new records will be inserted.
    ///   Use `false` when fetching additional subsequent pages of results, or
    ///   whenever `models` is a subset of the total data.
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are inserted into.
    public func save<Record>(
        entity: Record.Type,
        models: [Record.ModelType],
        shouldOverwrite: Bool,
        context: NSManagedObjectContext? = nil
    ) throws where Record: RecordFromModel, Record: NSManagedObject {
        if shouldOverwrite {
            try saveWithOverwrite(entity: entity, models: models, context: context)
        } else {
            try saveWithoutOverwrite(entity: entity, models: models, context: context)
        }
    }

    // Converts an array of models to Core Data records and saves them.
    // All existing records for this entity will be deleted and
    // new records matching `models` will be inserted.
    private func saveWithOverwrite<Record>(
        entity: Record.Type,
        models: [Record.ModelType],
        context: NSManagedObjectContext? = nil
    ) throws where Record: RecordFromModel, Record: NSManagedObject {
        let context = context ?? workerContext

        // delete all existing records
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        var caught: Error?
        
        context.performAndWait {
            do {
                try context.execute(deleteRequest)
                
                for model in models {
                    let record: Record = Record(context: context)
                    
                    // populate the record from the model
                    record.fromModel(model)
                }
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
        
        try context.saveChangesAndWait()
    }

    // Converts an array of models to Core Data records and saves them.
    // Existing records will be updated, new records will be inserted, and any duplicates will be removed.
    private func saveWithoutOverwrite<Record>(
        entity: Record.Type,
        models: [Record.ModelType],
        context: NSManagedObjectContext? = nil
    ) throws where Record: RecordFromModel, Record: NSManagedObject {
        guard !models.isEmpty else {
            return
        }

        let context = context ?? workerContext

        // Sort the models by uid
        let models = models.sorted(by: { $0.uid < $1.uid })

        // Perform a single fetch
        let request = NSFetchRequest<Record>(entityName: entity.entityName)
        // results should be sorted by uid just like our models
        request.sortDescriptors = [NSSortDescriptor(key: entity.uidKey, ascending: true)]
        // We only need those records matching the models we're inserting
        request.predicate = NSPredicate(format: "\(entity.uidKey) in %@", models.map { $0.uid })

        var caught: Error?
        
        context.performAndWait {
            do {
                let records: [Record] = try context.fetch(request)

                var recordIndex = 0
                let recordCount = records.count
                var fetchedRecord: Record?

                for model in models {
                    fetchedRecord = (recordIndex < recordCount) ? records[recordIndex] : nil

                    let record: Record

                    if let fetched = fetchedRecord,
                       fetched.uid == model.uid {
                        // We found a record with matching uid, let's update it
                        record = fetched
                        // move to the next fetched record
                        recordIndex += 1

                        // Remove any duplicates we might have fetched
                        while let fetched = (recordIndex < recordCount) ? records[recordIndex] : nil,
                              fetched.uid == model.uid {
                            context.delete(fetched)
                            // move to the next fetched record
                            recordIndex += 1
                        }
                    } else {
                        // No record with matching uid found, let's insert a new one
                        record = Record(context: context)
                    }

                    // populate the record from the model
                    record.fromModel(model)
                }
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
        
        try context.saveChangesAndWait()
    }
}
