//
//  PersistentManager+Fetch.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    /// Fetches managed object records from Core Data.
    /// May be safely called from any thread, but the managed objects returned
    /// may only be safely accessed from the current thread.
    /// - Parameters:
    ///   - predicate: optional predicate to filter records
    ///   - sortDescriptors: optional sort to apply to fetched records
    /// - Returns: an array of managed object records matching the (optional) predicate and optionally sorted
    /// - Throws: any error executing the fetch request
    public func fetchRecords<T: DataRecord>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] {
        let context = contextForThread()
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }

        fetchRequest.returnsObjectsAsFaults = false

        return try context.fetch(fetchRequest)
    }

    /// Fetches records from Core Data and convert those to models.
    /// May be safely called from any thread, and the models returned may be safely transferred to any thread.
    /// - Parameters:
    ///   - entity: the Core Data entity to be fetched
    ///   - uids: an array of uids to filter by. `nil` means to return all records. Default = nil.
    /// - Returns: an unsorted array of model objects matching the uids
    /// - Throws: any error executing the fetch request
    public func fetchModels<T: RecordToModel>(
        entity: T.Type,
        uids: [T.UidType]? = nil
    ) throws -> [T.ModelType] {
        var predicate: NSPredicate?

        if let uids = uids,
           !uids.isEmpty {
            predicate = NSPredicate(format: "\(entity.uidKey) in %@", uids)
        }

        let records: [T] = try fetchRecords(predicate: predicate)
        return records.map { $0.toModel() }
    }

    /// Fetches a single matching record from Core Data and convert it to a model object.
    /// May be safely called from any thread, and the model returned may be safely transferred to any thread.
    /// - Parameters:
    ///   - entity: the type of entity we want to fetch the records
    ///   - uid: the unique identifier of the record to filter for
    /// - Returns: the matching model object if found, otherwise nil.
    /// - Throws: any error executing the fetch request
    public func fetchModel<T: RecordToModel>(
        entity: T.Type,
        uid: T.UidType
    ) throws -> T.ModelType? {
        try fetchModels(entity: entity, uids: [uid]).first
    }
}
