//
//  GroceryProduct.swift
//  YPersistence
//
//  Created by Mark Pospesel on 11/16/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation
import YPersistence

public struct GroceryProduct: CoreModel, Equatable {
    public let uid: String
    public let name: String
    public let points: Int
    public let description: String?

    public init(uid: String, name: String, points: Int, description: String?) {
        self.uid = uid
        self.name = name
        self.points = points
        self.description = description
    }
}

extension GroceryProduct {
    static var durian = GroceryProduct(
        uid: "1",
        name: "Durian",
        points: 600,
        description: "A fruit with a distinctive scent."
    )

    static var banana = GroceryProduct(
        uid: "2",
        name: "Banana",
        points: 100,
        description: "A fruit with a yellow peel."
    )

    static var mango = GroceryProduct(
        uid: "3",
        name: "Mango",
        points: 200,
        description: "Deliciously refreshing."
    )

    static var blackberry = GroceryProduct(
        uid: "4",
        name: "Blackberry",
        points: 750,
        description: "Reminiscent of the Shenandoah mountains"
    )
}
