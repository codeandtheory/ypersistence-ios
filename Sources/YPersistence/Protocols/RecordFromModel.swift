//
//  RecordFromModel.swift
//  YPersistence
//
//  Created by Sumit Goswami on 29/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a Core Data record that can be populated from a model object.
public protocol RecordFromModel: ModelRepresentable {
    /// Populate the Core Data record from the provided model object
    func fromModel(_ model: ModelType)
}
