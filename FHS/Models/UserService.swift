//
//  UserService.swift
//  FHS
//
//  Created by Daniel Bevenius on 01/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class UserService {

    private let coreDataStack: CoreDataStack
    private let context: NSManagedObjectContext
    private let userWorkoutEntityName = "UserWorkout"
    private let workoutInfoEntityName = "WorkoutInfo"

    public class func newUserService() -> UserService {
        let coreDataStack: CoreDataStack = CoreDataStack(modelName: "User", storeNames: ["User"])
        return UserService(coreDataStack: coreDataStack)
    }

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        context = coreDataStack.context
    }

    public func newUserWorkout() -> UserWorkoutBuilder {
        return UserWorkoutBuilder(userService: self, id: NSUUID().UUIDString)
    }

    public func newUserWorkout(id: String) -> UserWorkoutBuilder {
        return UserWorkoutBuilder(userService: self, id: id)
    }

    public func updateUserWorkout(userWorkout: UserWorkout) -> UpdateUserWorkoutBuilder {
        return UpdateUserWorkoutBuilder(userService: self, userWorkout: userWorkout)
    }

    public func fetchLatestUserWorkout() -> UserWorkout? {
        let fetchRequest = NSFetchRequest(entityName: userWorkoutEntityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        if let results = context.executeFetchRequest(fetchRequest, error: &error) as! [UserWorkout]? {
            if results.count == 0 {
                return nil
            } else {
                return results[0]
            }
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchPerformedWorkoutInfo(workoutName: String) -> WorkoutInfo? {
        let fetchRequest = NSFetchRequest(entityName: workoutInfoEntityName)
        fetchRequest.predicate = NSPredicate(format: "workoutName == %@", workoutName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        if let results = context.executeFetchRequest(fetchRequest, error: &error) as! [WorkoutInfo]? {
            return results.first
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    private func saveContext() {
        var error: NSError?
        if !coreDataStack.context.save(&error) {
            debugPrintln("Could not save \(error), \(error?.userInfo)")
        }
    }

    private func insertNewUserWorkout() -> UserWorkout {
        let userWorkoutEntity = NSEntityDescription.entityForName("UserWorkout", inManagedObjectContext: context)
        return UserWorkout(entity: userWorkoutEntity!, insertIntoManagedObjectContext: coreDataStack.context)
    }

    private func insertNewWorkoutInfo() -> WorkoutInfo {
        let workoutInfoEntity = NSEntityDescription.entityForName("WorkoutInfo", inManagedObjectContext: context)
        return WorkoutInfo(entity: workoutInfoEntity!, insertIntoManagedObjectContext: coreDataStack.context)
    }

    public class UserWorkoutBuilder: UpdateUserWorkoutBuilder {

        convenience init(userService: UserService, id: String) {
            let userWorkout = userService.insertNewUserWorkout()
            userWorkout.id = id
            userWorkout.date = NSDate()
            userWorkout.duration = 0.0
            self.init(userService: userService, userWorkout: userWorkout)
        }

        public func date(date: NSDate) -> Self {
            userWorkout.date = date
            return self
        }

        public func duration(duration: Double) -> Self {
            userWorkout.duration = duration
            return self
        }

        public func category(category: String) -> Self {
            userWorkout.category = category
            return self
        }

        public func category(category: WorkoutCategory) -> Self {
            userWorkout.category = category.rawValue
            return self
        }

    }

    public class UpdateUserWorkoutBuilder {

        let userService: UserService
        var userWorkout: UserWorkout
        var workoutInfos: NSMutableOrderedSet

        init(userService: UserService, userWorkout: UserWorkout) {
            self.userService = userService
            self.userWorkout = userWorkout
            self.workoutInfos = userWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        }

        public func addToDuration(duration: Double) -> Self {
            userWorkout.duration += duration
            return self
        }

        public func done(done: Bool) -> Self {
            userWorkout.done = done
            return self
        }

        public func addWorkout(workoutName: String?) -> Self {
            if let name = workoutName {
                let workoutInfo = userService.insertNewWorkoutInfo()
                workoutInfo.workoutName = name
                workoutInfo.date = NSDate()
                workoutInfos.addObject(workoutInfo)
                userWorkout.workouts = workoutInfos.copy() as! NSOrderedSet
            }
            return self
        }

        public func updateDuration(workoutName: String, duration: Double) -> Self {
            workoutInfos.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                let workoutInfo = elem as! WorkoutInfo
                if workoutInfo.workoutName == workoutName {
                    workoutInfo.duration = duration
                    stop.initialize(true)
                }
            }
            return self
        }

        public func save() -> UserWorkout {
            userService.saveContext()
            return userWorkout
        }
        
    }

}
