//
//  NSManagedObjectContext+SaveChanges.swift
//  YPersistence
//
//  Created by Sanjib Chakraborty on 29/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import CoreData

/// Completion handler for `saveChanges(:)` and `saveChangesAndWait(:)`.
/// Returns nil if successful, otherwise returns the error thrown during the call to `NSManagedObjectContext.save()`.
public typealias SaveCompletion = (Error?) -> Void

extension NSManagedObjectContext {
    /// Asynchronous save method. Performs the save asychronously on the context's queue.
    /// Recursively calls `saveChanges(:)` on any parent context.
    /// Does nothing if there are no changes to save.
    /// - Parameter completion: returns nil if successful, otherwise returns an error
    public func saveChanges(_ completion: SaveCompletion? = nil) {
        perform { [weak self] in
            guard let self = self else { return }

            guard self.hasChanges else {
                completion?(nil)
                return
            }
            
            do {
                try self.save()

                if let parentContext = self.parent {
                    parentContext.saveChanges(completion)
                } else {
                    completion?(nil)
                }
            } catch {
                completion?(error)
            }
        }
    }

    /// Synchronous save method. Performs the save sychronously on the context's queue.
    /// Recursively calls `saveChangesAndWait(:)` on any parent context.
    /// Does nothing if there are no changes to save.
    /// - Throws: any error thrown from `save()` on this context or any parent context.
    public func saveChangesAndWait() throws {
        var caught: Error?
        
        performAndWait {
            guard hasChanges else {
                return
            }
            do {
                try save()
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
        
        if let parentContext = parent {
            try parentContext.saveChangesAndWait()
        }
    }
}
