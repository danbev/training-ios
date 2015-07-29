//
//  TestCoreDataStack.swift
//  FHR
//
//  Created by Daniel Bevenius on 05/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import FHS
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {

    override init(storeName: String) {
        super.init(storeName: storeName)
        self.psc = {
            var psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.model)
            var error: NSError? = nil
            var ps = psc!.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
            if (ps == nil) {
                abort()
            }
            return psc
        }()
    }

}
