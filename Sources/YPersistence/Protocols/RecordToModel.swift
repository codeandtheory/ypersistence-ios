//
//  RecordToModel.swift
//  YPersistence
//
//  Created by Sumit Goswami on 08/11/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a Core Data record that can be converted into a model object
public protocol RecordToModel: ModelRepresentable {
    /// Convert the Core Data record into a model object
    func toModel() -> ModelType
}
