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
    public let storeNames: [String]
    private static let storesDirectoryName = "stores"

    public lazy var context: NSManagedObjectContext! = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.psc
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    public init(modelName: String, storeNames: [String], copyStore: Bool = false) {
        self.storeNames = storeNames
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

    public class func storeDirectory() -> NSURL {
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let storesDir = documentUrl.URLByAppendingPathComponent(storesDirectoryName, isDirectory: true)
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        if !fileManager.fileExistsAtPath(storesDir.path!) {
            fileManager.createDirectoryAtURL(storesDir, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
        return storesDir
    }

    public class func copyDefaultStore(storeName: String) -> Bool {
        return false
    }

    public class func listStoreNames() -> [String] {
        let storesDir = CoreDataStack.storeDirectory()
        var storeNames = [String]()
        var error: NSError?
        let optionalFiles = NSFileManager.defaultManager().contentsOfDirectoryAtURL(storesDir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,error: &error)
        // TODO: should be able to use filter instead here
        if let files = optionalFiles {
            for file in files as! [NSURL] {
                if file.pathExtension == "sqlite" {
                    storeNames.append(file.lastPathComponent!.stringByDeletingPathExtension)
                }
            }
        }
        return storeNames
    }

    public class func newStore(storeName: String, modelName: String) -> NSURL {
        let mainBundle = NSBundle.mainBundle()
        let fhsModelUrl = mainBundle.URLForResource(modelName, withExtension: "momd")
        let model = NSManagedObjectModel(contentsOfURL: fhsModelUrl!)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let fileManager = NSFileManager.defaultManager()
        let storesDir = CoreDataStack.storeDirectory()
        let storeUrl = storesDir.URLByAppendingPathComponent("\(storeName).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError?
        let store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeUrl,
                options: options,
                error: &error)!
        return storeUrl
    }

    public class func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        //debugPrintln("Documents directory: \(urls[0])")
        return urls[0]
    }

    public class func copyStoreFromBundle(storeName: String) -> NSURL {
        let mainBundle = NSBundle.mainBundle()
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let sqliteName = "\(storeName).sqlite"
        let fileManager = NSFileManager.defaultManager()

        let storesDir = documentUrl.URLByAppendingPathComponent(storesDirectoryName, isDirectory: true)
        println("Creating \(storesDir)")
        var error: NSError?
        if !fileManager.fileExistsAtPath(storesDir.path!) {
            fileManager.createDirectoryAtURL(storesDir, withIntermediateDirectories: false, attributes: nil, error: &error)
        }

        let storeUrl = storesDir.URLByAppendingPathComponent(sqliteName)
        if !fileManager.fileExistsAtPath(storeUrl.path!) {
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
        return storeUrl
    }

}
