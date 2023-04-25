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
    /// - Parameter context: optional managed context to use. Default is `nil`.
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
    /// - Parameter context: optional managed context to use. Default is `nil`.
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
    /// - Parameter context: optional managed context to use. Default is `nil`.
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

    /// Mark records as uploaded. Do this after they have been been successfully uploaded to remote.
    ///
    /// May be safely called from any thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - entity: the Core Data entity to be fetched
    ///   - uids: array of uids to update
    ///   - context: optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markRecordsAsUploaded<T: SyncRecord>(
        entity: T.Type,
        uids: [T.UidType],
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext

        let predicate = NSPredicate(format: "\(T.isUploadedKey) == false && \(entity.uidKey) in %@", uids)
        
        let records: [T] = try fetchRecords(
            predicate: predicate,
            context: context
        )

        for record in records {
            record.isUploaded = true
        }

        try context.saveChangesAndWait()
    }

    /// Mark selected records as being deleted locally.
    /// Any local fetches should exclude records where `wasDeleted == true`.
    /// Once these records have been deleted from remote, you can safely delete them locally.
    ///
    /// May be safely called from any thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - entity: the Core Data entity to be fetched
    ///   - uids: array of uids to update
    ///   - context: optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markRecordsAsDeleted<T: SyncRecord>(
        entity: T.Type,
        uids: [T.UidType],
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext

        let predicate = NSPredicate(format: " \(T.wasDeletedKey) == false && \(entity.uidKey) in %@", uids)

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

    /// Mark all records as being deleted locally. Any local fetches should exclude records where `wasDeleted == true`.
    /// Once these records have been deleted from remote, you can safely delete them locally.
    ///
    /// May be safely called from any thread.
    /// If no context is provided, a worker context will be created.
    /// - Parameters:
    ///   - entity: the Core Data entity to be fetched
    ///   - context: optional managed context to use. Default is `nil`.
    /// - Throws: any error executing the fetch or save request
    public func markAllRecordsAsDeleted<T: SyncRecord>(
        entity: T.Type,
        context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? workerContext
        let predicate = NSPredicate(format: "\(entity.wasDeletedKey) == false")

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
