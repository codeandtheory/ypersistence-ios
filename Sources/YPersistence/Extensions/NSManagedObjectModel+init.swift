//
//  NSManagedObjectModel+init.swift
//  YPersistence
//
//  Created by Karthik K Manoj on 03/06/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import CoreData

extension NSManagedObjectModel {
    convenience init?(from modelName: String, in bundle: Bundle) {
        guard let url = bundle.url(forResource: modelName, withExtension: "momd") else { return nil }
        self.init(contentsOf: url)
    }
}
