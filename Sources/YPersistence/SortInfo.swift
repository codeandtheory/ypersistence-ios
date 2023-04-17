//
//  SortInfo.swift
//  YPersistence
//
//  Created by Sahil Saini on 17/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Sort attribute (column) name info collection
public struct SortInfo: Equatable {
    /// Collection of the receivers, attribute (column) name
    public let columns: [SortColumn]

    /// Converts the collection of the receivers to a sort descriptor collection
    public var descriptors: [NSSortDescriptor] {
        columns.map { NSSortDescriptor(key: $0.key, ascending: $0.ascending) }
    }
}
