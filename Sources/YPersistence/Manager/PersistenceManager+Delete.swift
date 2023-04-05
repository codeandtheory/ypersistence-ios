//
//  PersistenceManager+Delete.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    /// Delete records matching the specified predicate.
    /// - Parameters:
    ///   - entityName: the name of the entity to delete from
    ///   - predicate: the predicate used to filter the records. `nil` means delete all records.
    ///   - saveEvery: chunk size for saving during large deletes. Default = 500
    ///   - context: Optional managed context to use. Default = nil.
    ///   If nil a short-lived `workerContext` will be created.
    ///   Either way `saveChangesAndWait()` will be called on the context.
    ///   Typically you would just pass `nil` unless you specifically need to control which
    ///   context the records are deleted from.
    /// - Throws: any error saving the context after the deletion.
    func delete(
        entityName: String,
        predicate: NSPredicate?,
        saveEvery: Int = 500,
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        
        var caught: Error?
        
        context.performAndWait {
            do {
                let records: [NSManagedObject] = try context.fetch(request)
                var unsavedCount: Int = 0
                try records.forEach {
                    context.delete($0)
                    unsavedCount += 1
                    if unsavedCount >= saveEvery {
                        try context.saveChangesAndWait()
                        unsavedCount = 0
                    }
                }
                
                if unsavedCount > 0 {
                    try context.saveChangesAndWait()
                    unsavedCount = 0
                }
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
    }

    /// Delete records with the matching unique identifier
    /// - Parameters:
    ///   - entity: the entity to delete from
    ///   - uid: the unique identifier of the object(s) to delete
    /// - Throws: any error saving the context after the deletion.
    public func delete<Record: DataRecord>(entity: Record.Type, uid: Record.UidType) throws {
        try delete(entity: entity, uids: [uid])
    }

    /// Delete records with the matching unique identifiers
    /// - Parameters:
    ///   - entity: the entity to delete from
    ///   - uid: the unique identifiers of the objects to delete
    /// - Throws: any error saving the context after the deletion.
    public func delete<Record: DataRecord>(entity: Record.Type, uids: [Record.UidType]) throws {
        let predicate = NSPredicate(format: "\(entity.uidKey) in %@", uids)
        try delete(entityName: entity.entityName, predicate: predicate)
    }

    /// Delete the specified model.
    /// Note: deletes all records having the same uid as the model.
    /// - Parameters:
    ///   - entity: the entity to delete from
    ///   - model: the business model object to delete
    /// - Throws: any error saving the context after the deletion.
    public func deleteModel<Record: ModelRepresentable>(entity: Record.Type, model: Record.ModelType) throws {
        try deleteModels(entity: entity, models: [model])
    }

    /// Delete the specified models.
    /// Note: deletes all records having the same uids as the models.
    /// - Parameters:
    ///   - entity: the entity to delete from
    ///   - models: the business model objects to delete
    /// - Throws: any error saving the context after the deletion.
    public func deleteModels<Record: ModelRepresentable>(entity: Record.Type, models: [Record.ModelType]) throws {
        try delete(entity: entity, uids: models.compactMap({ $0.uid as? Record.UidType }))
    }
}
