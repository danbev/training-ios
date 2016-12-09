//
//  TestCoreDataStack.swift
//  FHR
//
//  Created by Daniel Bevenius on 05/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData
import FHS

class TestCoreDataStack: CoreDataStack {

    override init(storeNames: [String], storeDirectory: URL, modelUrl: URL) {
        super.init(storeNames: storeNames, storeDirectory: storeDirectory, modelUrl: modelUrl)
        self.psc = {
            let psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.model)
            var ps: NSPersistentStore?
            do {
                ps = try psc!.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch let error as NSError {
                print(error)
                ps = nil
            } catch {
                fatalError()
            }
            if (ps == nil) {
                abort()
            }
            return psc
        }()
    }
    
}
