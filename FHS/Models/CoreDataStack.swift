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

    public class func storesFromBundle(storeNames: [String], modelName: String) -> CoreDataStack {
        let directory = CoreDataStack.storeDirectory()
        let modelUrl = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd")!
        return CoreDataStack(storeNames: storeNames, storeDirectory: directory, modelUrl: modelUrl)
    }

    public class func newWorkoutStore(storeUrl: NSURL, modelUrl: NSURL) -> CoreDataStack? {
        let directory = (storeUrl.absoluteString as NSString).stringByDeletingLastPathComponent
        let storeDirectory = NSURL(fileURLWithPath: directory, isDirectory: true)
        let storeName = (directory as NSString).lastPathComponent
        return CoreDataStack(storeNames: [storeName], storeDirectory: storeDirectory, modelUrl: modelUrl)
    }

    public init(storeNames: [String], storeDirectory: NSURL, modelUrl: NSURL) {
        self.storeNames = storeNames
        let documentUrl = storeDirectory
        //let mainBundle = NSBundle.mainBundle()
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        model = NSManagedObjectModel(contentsOfURL: modelUrl)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        for storeName in storeNames {
            let sqliteName = "\(storeName).sqlite"
            let storeUrl = documentUrl.URLByAppendingPathComponent(sqliteName)
            //var error:NSError? = nil
            store = try! psc!.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeUrl,
                options: options)
        }
    }

    func saveContext() {
        var error: NSError? = nil
        if context.hasChanges {
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                debugPrint("Could not save \(error), \(error?.userInfo)")
            }
        }
    }

    public class func storeDirectory() -> NSURL {
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let storesDir = documentUrl.URLByAppendingPathComponent(storesDirectoryName, isDirectory: true)
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(storesDir.path!) {
            do {
                try fileManager.createDirectoryAtURL(storesDir, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
        }
        return storesDir
    }

    public class func listStoreNames() -> [String] {
        let storesDir = CoreDataStack.storeDirectory()
        var storeNames = [String]()
        let optionalFiles: [AnyObject]?
        do {
            optionalFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(storesDir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        } catch let error as NSError {
            print(error)
            optionalFiles = nil
        }
        // TODO: should be able to use filter instead here
        if let files = optionalFiles {
            for file in files as! [NSURL] {
                if file.pathExtension == "sqlite" {
                    storeNames.append((file.lastPathComponent! as NSString).stringByDeletingPathExtension)
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
        let _ = NSFileManager.defaultManager()
        let storesDir = CoreDataStack.storeDirectory()
        let storeUrl = storesDir.URLByAppendingPathComponent("\(storeName).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        let _ = try! psc.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeUrl,
                options: options)
        return storeUrl
    }

    public class func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) 
        return urls[0]
    }

    public class func copyStoreFromBundle(storeName: String) -> NSURL {
        let mainBundle = NSBundle.mainBundle()
        let documentUrl = CoreDataStack.storeDirectory()
        let sqliteName = "\(storeName).sqlite"
        let fileManager = NSFileManager.defaultManager()

        let storesDir = documentUrl.URLByAppendingPathComponent(storesDirectoryName, isDirectory: true)
        if !fileManager.fileExistsAtPath(storesDir.path!) {
            do {
                try fileManager.createDirectoryAtURL(storesDir, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
        }

        let storeUrl = storesDir.URLByAppendingPathComponent(sqliteName)
        if !fileManager.fileExistsAtPath(storeUrl.path!) {
            let sourceSqliteURLs = [mainBundle.URLForResource(storeName, withExtension: "sqlite")!,
                mainBundle.URLForResource(storeName, withExtension: "sqlite-wal")!,
                mainBundle.URLForResource(storeName, withExtension: "sqlite-shm")!]
            let destSqliteURLs = [documentUrl.URLByAppendingPathComponent(sqliteName),
                documentUrl.URLByAppendingPathComponent("\(sqliteName)-wal"),
                documentUrl.URLByAppendingPathComponent("\(sqliteName)-shm")]
            for var index = 0; index < sourceSqliteURLs.count; index++ {
                do {
                    try fileManager.copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index])
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        return storeUrl
    }

}
