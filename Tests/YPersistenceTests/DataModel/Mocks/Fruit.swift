//
//  Fruit.swift
//  YPersistence
//
//  Created by Sahil Saini on 19/04/23.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import YPersistence

public struct Fruit: CoreModel, Equatable {
    public let uid: String
    public let name: String
    public let isUploaded: Bool
    public let wasDeleted: Bool

    public init(uid: String, name: String, isUploaded: Bool, wasDeleted: Bool) {
        self.uid = uid
        self.name = name
        self.isUploaded = isUploaded
        self.wasDeleted = wasDeleted
    }
}

extension Fruit {
    static var mango = Fruit(
        uid: "1",
        name: "Mango",
        isUploaded: true,
        wasDeleted: true
    )

    static var banana = Fruit(
        uid: "2",
        name: "Banana",
        isUploaded: true,
        wasDeleted: false
    )

    static var apple = Fruit(
        uid: "3",
        name: "Apple",
        isUploaded: false,
        wasDeleted: false
    )

    static var grapes = Fruit(
        uid: "4",
        name: "Grapes",
        isUploaded: false,
        wasDeleted: true
    )
}
