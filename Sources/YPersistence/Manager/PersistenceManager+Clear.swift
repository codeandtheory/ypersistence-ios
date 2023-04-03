//
//  PersistenceManager+Clear.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

extension PersistenceManager {
    /// List of all entities to be erased upon `clear()`.
    /// Default = list of all entities in the model, which would erase all entities in the database.
    /// Override this to customize the list of entities specific to your use-case.
    /// You may wish to list child entities before parents and you may wish to
    /// exclude certain entities from being cleared. For example, on user logout
    /// you should clear all user-specific data, but you may wish to preserve some
    /// generic information that is not tied to the user.
    /// - Returns: an array of entity names to be cleared.
    @objc open func entityNamesForClear() -> [String] {
        container.persistentStoreCoordinator.managedObjectModel.entities
            .compactMap({ $0.name })
    }

    /// Clear the datbase model. By default this will fetch a list of entity names via
    /// `entityNamesForClear` and then delete all records from each of them using
    /// `batchDeleteAll(entityName:context:)`.
    /// Override to customize the clear behavior you desire. You may choose to erase via
    /// `manualDeleteAll(entityName:saveEvery:context:)`.
    /// If you really wish to completely erase all data and start over, consider using `destroy(completion:)` instead.
    /// - Throws: any error executing the delete or subsequent save.
    @objc open func clear() throws {
        let context = workerContext
        try entityNamesForClear().forEach {
            try self.batchDeleteAll(entityName: $0, context: context)
        }
    }
}
