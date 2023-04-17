//
//  SortColumn.swift
//  YPersistence
//
//  Created by Sahil Saini on 13/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Describes an attribute (column) sort
public struct SortColumn: Equatable {
    /// Sort attribute (column) name
    public let key: String
    /// Sort order. Default is `true`.
    public let ascending: Bool

    /// Converts the receiver to a sort descriptor
    public var descriptor: NSSortDescriptor {
        NSSortDescriptor(key: key, ascending: ascending)
    }

    /// Initializes a sort column
    /// - Parameters:
    ///   - key: sort attribute (column) name
    ///   - ascending: sort order. Default is `true`.
    public init(key: String, ascending: Bool = true) {
        self.key = key
        self.ascending = ascending
    }
}
