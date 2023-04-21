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

    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

extension Fruit {
    static let mango = Fruit(
        uid: "1",
        name: "Mango"
    )

    static let banana = Fruit(
        uid: "2",
        name: "Banana"
    )

    static let apple = Fruit(
        uid: "3",
        name: "Apple"
    )

    static let grapes = Fruit(
        uid: "4",
        name: "Grapes"
    )
}
