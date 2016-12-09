//
//  CoreDataStack.swift
//  FHR
//
//  Created by Daniel Bevenius on 22/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import CoreData

open class CoreDataStack {
    open var psc: NSPersistentStoreCoordinator?
    open var model: NSManagedObjectModel
    open var store: NSPersistentStore!
    open let storeNames: [String]
    fileprivate static let storesDirectoryName = "stores"

    open lazy var context: NSManagedObjectContext! = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.psc
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    open class func storesFromBundle(_ storeNames: [String], modelName: String) -> CoreDataStack {
        let directory = CoreDataStack.storeDirectory()
        let modelUrl = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return CoreDataStack(storeNames: storeNames, storeDirectory: directory, modelUrl: modelUrl)
    }

    open class func newWorkoutStore(_ storeUrl: URL, modelUrl: URL) -> CoreDataStack? {
        let directory = (storeUrl.absoluteString as NSString).deletingLastPathComponent
        let storeDirectory = URL(fileURLWithPath: directory, isDirectory: true)
        let storeName = (directory as NSString).lastPathComponent
        return CoreDataStack(storeNames: [storeName], storeDirectory: storeDirectory, modelUrl: modelUrl)
    }

    public init(storeNames: [String], storeDirectory: URL, modelUrl: URL) {
        self.storeNames = storeNames
        let documentUrl = storeDirectory
        //let mainBundle = NSBundle.mainBundle()
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        model = NSManagedObjectModel(contentsOf: modelUrl)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        for storeName in storeNames {
            let sqliteName = "\(storeName).sqlite"
            let storeUrl = documentUrl.appendingPathComponent(sqliteName)
            //var error:NSError? = nil
            store = try! psc!.addPersistentStore(ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeUrl,
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

    open class func storeDirectory() -> URL {
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let storesDir = documentUrl.appendingPathComponent(storesDirectoryName, isDirectory: true)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: storesDir.path) {
            do {
                try fileManager.createDirectory(at: storesDir, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
        }
        return storesDir
    }

    open class func listStoreNames() -> [String] {
        let storesDir = CoreDataStack.storeDirectory()
        var storeNames = [String]()
        let optionalFiles: [AnyObject]?
        do {
            optionalFiles = try FileManager.default.contentsOfDirectory(at: storesDir, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) as [AnyObject]?
        } catch let error as NSError {
            print(error)
            optionalFiles = nil
        }
        // TODO: should be able to use filter instead here
        if let files = optionalFiles {
            for file in files as! [URL] {
                if file.pathExtension == "sqlite" {
                    storeNames.append((file.lastPathComponent as NSString).deletingPathExtension)
                }
            }
        }
        return storeNames
    }

    open class func newStore(_ storeName: String, modelName: String) -> URL {
        let mainBundle = Bundle.main
        let fhsModelUrl = mainBundle.url(forResource: modelName, withExtension: "momd")
        let model = NSManagedObjectModel(contentsOf: fhsModelUrl!)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let _ = FileManager.default
        let storesDir = CoreDataStack.storeDirectory()
        let storeUrl = storesDir.appendingPathComponent("\(storeName).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        let _ = try! psc.addPersistentStore(ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeUrl,
                options: options)
        return storeUrl
    }

    open class func applicationDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) 
        return urls[0]
    }

    open class func copyStoreFromBundle(_ storeName: String) -> URL {
        let mainBundle = Bundle.main
        let documentUrl = CoreDataStack.storeDirectory()
        let sqliteName = "\(storeName).sqlite"
        let fileManager = FileManager.default

        let storesDir = documentUrl.appendingPathComponent(storesDirectoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: storesDir.path) {
            do {
                try fileManager.createDirectory(at: storesDir, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
        }

        let storeUrl = storesDir.appendingPathComponent(sqliteName)
        if !fileManager.fileExists(atPath: storeUrl.path) {
            let sourceSqliteURLs = [mainBundle.url(forResource: storeName, withExtension: "sqlite")!,
                mainBundle.url(forResource: storeName, withExtension: "sqlite-wal")!,
                mainBundle.url(forResource: storeName, withExtension: "sqlite-shm")!]
            let destSqliteURLs = [documentUrl.appendingPathComponent(sqliteName),
                documentUrl.appendingPathComponent("\(sqliteName)-wal"),
                documentUrl.appendingPathComponent("\(sqliteName)-shm")]
            for index in 0 ..< sourceSqliteURLs.count {
                do {
                    try fileManager.copyItem(at: sourceSqliteURLs[index], to: destSqliteURLs[index])
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        return storeUrl
    }

}
