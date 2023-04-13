//
//  SortColumn.swift
//  YPersistence
//
//  Created by Sahil Saini on 13/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Sort the columns
public struct SortColumn: Equatable {
    /// Key for performing a comparison
    public let key: String
    /// Decides order of sorting. Default is `true`.
    public let ascending: Bool
    /// Sort descriptor with a specified key path and ordering
    public var descriptor: NSSortDescriptor {
        NSSortDescriptor(key: key, ascending: ascending)
    }
    /// Initializes a SortColumn
    /// - Parameters:
    ///   - key: key for performing a comparison
    ///   - ascending: specifies if sorting in ascending order. Default is `true`.
    public init(key: String, ascending: Bool = true) {
        self.key = key
        self.ascending = ascending
    }
}
