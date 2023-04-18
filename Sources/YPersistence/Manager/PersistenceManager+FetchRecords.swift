//
//  PersistenceManager+FetchRecords.swift
//  YPersistence
//
//  Created by Sahil Saini on 18/04/23.
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
    ///   - context: context to fetch data
    /// - Returns: an array of managed object records matching the (optional) predicate and optionally sorted
    /// - Throws: any error executing the fetch request
    internal func fetchRecords<T: DataRecord>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let context = context ?? contextForThread()
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
}
