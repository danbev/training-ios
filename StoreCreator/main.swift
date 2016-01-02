//
//  main.swift
//  StoreCreator
//
//  Created by Daniel Bevenius on 01/09/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

var workoutsFile: String?
var storeName: String?

for arg in Process.arguments {
    if arg.rangeOfString("file") != nil {
        workoutsFile = arg.substringFromIndex(advance(arg.startIndex, 5))
    }
    if arg.rangeOfString("storeName") != nil {
        storeName = arg.substringFromIndex(advance(arg.startIndex, 10))
    }
}

if workoutsFile == nil || storeName == nil {
    print("Usage: \(Process.arguments[0]) file=workouts.json storeName=SomeName")
    exit(1)
}

let fileManager = NSFileManager.defaultManager()
let pwd = NSURL.fileURLWithPath(fileManager.currentDirectoryPath)!
let fileUrl = pwd.URLByAppendingPathComponent(workoutsFile!)
if fileManager.fileExistsAtPath(fileUrl.path!) {
    let modelUrl = pwd.URLByAppendingPathComponent("model/FHS.mom")
    let storeUrl = pwd.URLByAppendingPathComponent(storeName!).filePathURL!
    let coreDataStack = CoreDataStack.newWorkoutStore(storeUrl, modelUrl: modelUrl)!
    let workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: coreDataStack))
    print("Found file = \(fileUrl), storeUrl=\(storeUrl), modelUrl=\(modelUrl)")
    workoutService.importData(fileUrl)
}

