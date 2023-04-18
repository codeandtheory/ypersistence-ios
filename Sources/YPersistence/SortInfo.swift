//
//  SortInfo.swift
//  YPersistence
//
//  Created by Sahil Saini on 17/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Describes a mult-attribute (column) sort
public struct SortInfo: Equatable {
    /// Columns
    public let columns: [SortColumn]

    /// Converts the receiver to an array of sort descriptors.
    public var descriptors: [NSSortDescriptor] {
        columns.map { $0.descriptor }
    }

    /// Initializes a sort info
    /// - Parameter columns: columns
    public init(columns: [SortColumn]) {
        self.columns = columns
    }
}
