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
    public var store: NSPersistentStore

    public lazy var context: NSManagedObjectContext! = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.psc
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    public init(storeName: String) {
        let bundle = NSBundle.mainBundle()
        let modelUrl = bundle.URLForResource(storeName, withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelUrl!)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let documentUrl = CoreDataStack.applicationDocumentsDirectory()
        let storeUrl = documentUrl.URLByAppendingPathComponent(storeName)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var error:NSError? = nil
        store = psc!.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil,
            URL: storeUrl,
            options: options,
            error: &error)!
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
        return urls[0]
    }

}
