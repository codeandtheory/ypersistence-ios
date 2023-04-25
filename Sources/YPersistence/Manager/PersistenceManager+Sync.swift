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
    /// Fetches records that are awaiting upload.
    ///
    /// May be safely called from any thread, but the managed objects returned
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameter context: Optional managed context to use. Default is `nil`.
    /// - Returns: an array of managed object records not uploaded
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToUpload<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(format: "\(T.isUploadedKey) == false")
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors,
            context: context
        )
    }

    /// Fetches records that have been updated (but not deleted) since the last sync.
    ///
    /// May be safely called from any thread, but the managed objects returned
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameter context: Optional managed context to use. Default is `nil`.
    /// - Returns: an array of managed object records to update
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToUpdate<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(
            format: "\(T.isUploadedKey) == false && \(T.wasDeletedKey) == false"
        )
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors,
            context: context
        )
    }

    /// Fetches records that have been marked for deletion since the last sync.
    ///
    /// May be safely called from any thread, but the managed objects returned
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Returns: an array of managed object records to delete.
    /// - Throws: any error executing the fetch request
    public func fetchRecordsToDelete<T: SyncRecord>(
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let predicate = NSPredicate(
            format: "\(T.isUploadedKey) == false && \(T.wasDeletedKey) == true"
        )
        return try fetchRecords(
            predicate: predicate,
            sortDescriptors: T.sort?.descriptors,
            context: context
        )
    }

    /// Update records that have been marked for upload since the last sync.
    ///
    /// May be safely called from any thread
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - enity: the Core Data entity to be fetched
    ///   - uids: array of uids to update
    ///   - context: Optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markRecordsAsUploaded<T: SyncRecord>(
        enity: T.Type,
        uids: [T.UidType],
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext

        let predicate = NSPredicate(format: "\(enity.uidKey) in %@ && \(T.isUploadedKey) == false", uids)
        
        let records: [T] = try fetchRecords(
            predicate: predicate,
            context: context
        )

        for record in records {
            record.isUploaded = true
        }

        try context.saveChangesAndWait()
    }

    /// Update records that have been marked for deletion since the last sync.
    ///
    /// May be safely called from any thread
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - enity: the Core Data entity to be fetched
    ///   - uids: array of uids to update
    ///   - context: Optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markRecordsAsDeleted<T: SyncRecord>(
        enity: T.Type,
        uids: [T.UidType],
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext

        let predicate = NSPredicate(format: "\(enity.uidKey) in %@ && \(T.wasDeletedKey) == false", uids)

        let records: [T] = try fetchRecords(
            predicate: predicate,
            context: context
        )

        for record in records {
            record.wasDeleted = true
            record.isUploaded = false
        }

        try context.saveChangesAndWait()
    }

    /// Update all records as deleted
    ///
    /// May be safely called from any thread
    /// may only be safely accessed from the current thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - enity: the Core Data entity to be fetched
    ///   - context: Optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markAllRecordsAsDeleted<T: SyncRecord>(
        enity: T.Type,
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext
        let predicate = NSPredicate(format: "\(enity.wasDeletedKey) == false")

        let records: [T] = try fetchRecords(
            predicate: predicate,
            context: context
        )

        for record in records {
            record.wasDeleted = true
            record.isUploaded = false
        }

        try context.saveChangesAndWait()
    }
}
