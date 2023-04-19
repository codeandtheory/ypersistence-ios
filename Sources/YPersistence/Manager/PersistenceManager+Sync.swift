//
//  PersistenceManager+Sync.swift
//  YPersistence
//
//  Created by Sahil Saini on 18/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    /// Fetches records from Core Data and convert those to models.
    /// May be safely called from any thread, and the models returned may be safely transferred to any thread.
    /// - Parameter context: Optional managed context to use. Default is `nil`.
    /// - Returns: array of model objects not uploaded
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToUpload<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(format: "\(T.isUploadedKey) == false")
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors
        )
    }

    /// Fetches records from Core Data and convert those to models.
    /// May be safely called from any thread, and the models returned may be safely transferred to any thread.
    /// - Parameter context: Optional managed context to use. Default is `nil`.
    /// - Returns: array of model objects to update
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToUpdate<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(
            format: "\(T.isUploadedKey) == false && \(T.wasDeletedKey) == false"
        )
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors
        )
    }

    /// Fetches records from Core Data and convert those to models.
    /// May be safely called from any thread, and the models returned may be safely transferred to any thread.
    /// - Returns: array of model objects to delete
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToDelete<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(
            format: "\(T.isUploadedKey) == false && \(T.wasDeletedKey) == true"
        )
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors
        )
    }
}
