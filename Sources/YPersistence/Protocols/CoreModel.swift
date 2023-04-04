//
//  CoreModel.swift
//  YPersistence
//
//  Created by Sumit Goswami on 29/10/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a uniquely identifiable model object.
/// This could be a `struct` or `class`. It just needs some sort of unique identifier.
public protocol CoreModel {
    /// The type of field used as unique identifier (String, Int, UInt, UUID, etc.)
    associatedtype UidType: UniqueIdentifier

    /// The model object's unique identifier
    var uid: UidType { get }
}
