//
//  CoreDataStack.swift
//  FHR
//
//  Created by Daniel Bevenius on 22/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import CoreData

public class CoreDataStack {
    public var psc: NSPersistentStoreCoordinator?
    public var model: NSManagedObjectModel
    public var store: NSPersistentStore!

    public lazy var context: NSManagedObjectContext! = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.psc
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    public init(modelName: String, storeNames: [String], copyStore: Bool = false) {
        let mainBundle = NSBundle.mainBundle()
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let fhsModelUrl = mainBundle.URLForResource(modelName, withExtension: "momd")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        model = NSManagedObjectModel(contentsOfURL: fhsModelUrl!)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)

        for storeName in storeNames {
            let sqliteName = "\(storeName).sqlite"
            let storeUrl = documentUrl.URLByAppendingPathComponent(sqliteName)
            let fileManager = NSFileManager.defaultManager()
            if copyStore && !fileManager.fileExistsAtPath(storeUrl.path!) {
                let sourceSqliteURLs = [mainBundle.URLForResource(storeName, withExtension: "sqlite")!,
                    mainBundle.URLForResource(storeName, withExtension: "sqlite-wal")!,
                    mainBundle.URLForResource(storeName, withExtension: "sqlite-shm")!]
                let destSqliteURLs = [documentUrl.URLByAppendingPathComponent(sqliteName),
                    documentUrl.URLByAppendingPathComponent("\(sqliteName)-wal"),
                    documentUrl.URLByAppendingPathComponent("\(sqliteName)-shm")]
                var error:NSError? = nil
                for var index = 0; index < sourceSqliteURLs.count; index++ {
                    fileManager.copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index], error: &error)
                }
            }
            var error:NSError? = nil
            store = psc!.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeUrl,
                options: options,
                error: &error)!
        }
    }

    func saveContext() {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            debugPrintln("Could not save \(error), \(error?.userInfo)")
        }
    }

    class func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        //debugPrintln("Documents directory: \(urls[0])")
        return urls[0]
    }

}
