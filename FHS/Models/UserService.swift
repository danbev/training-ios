//
//  UserService.swift
//  FHS
//
//  Created by Daniel Bevenius on 01/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

open class UserService {

    fileprivate let coreDataStack: CoreDataStack
    fileprivate let context: NSManagedObjectContext
    fileprivate let userWorkoutEntityName = "UserWorkout"
    fileprivate let workoutInfoEntityName = "WorkoutInfo"

    open class func newUserService() -> UserService {
        let coreDataStack: CoreDataStack = CoreDataStack.storesFromBundle(["User"], modelName: "User")
        return UserService(coreDataStack: coreDataStack)
    }

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        context = coreDataStack.context
    }

    open func newUserWorkout() -> UserWorkoutBuilder {
        return UserWorkoutBuilder(userService: self, id: UUID().uuidString)
    }

    open func newUserWorkout(_ id: String) -> UserWorkoutBuilder {
        return UserWorkoutBuilder(userService: self, id: id)
    }

    open func updateUserWorkout(_ userWorkout: UserWorkout) -> UpdateUserWorkoutBuilder {
        return UpdateUserWorkoutBuilder(userService: self, userWorkout: userWorkout)
    }

    open func fetchLatestUserWorkout() -> UserWorkout? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userWorkoutEntityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        do {
            if let results = try context.fetch(fetchRequest) as? [UserWorkout] {
                if results.count == 0 {
                    return nil
                } else {
                    return results[0]
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    open func fetchPerformedWorkoutInfo(_ workoutName: String) -> WorkoutInfo? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutInfoEntityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", workoutName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            if let results = try context.fetch(fetchRequest) as? [WorkoutInfo] {
                return results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    fileprivate func saveContext() {
        var error: NSError?
        do {
            try coreDataStack.context.save()
        } catch let error1 as NSError {
            error = error1
            debugPrint("Could not save \(error), \(error?.userInfo)")
        }
    }

    fileprivate func insertNewUserWorkout() -> UserWorkout {
        let userWorkoutEntity = NSEntityDescription.entity(forEntityName: "UserWorkout", in: context)
        return UserWorkout(entity: userWorkoutEntity!, insertInto: coreDataStack.context)
    }

    fileprivate func insertNewWorkoutInfo() -> WorkoutInfo {
        let workoutInfoEntity = NSEntityDescription.entity(forEntityName: "WorkoutInfo", in: context)
        return WorkoutInfo(entity: workoutInfoEntity!, insertInto: coreDataStack.context)
    }

    open class UserWorkoutBuilder: UpdateUserWorkoutBuilder {

        convenience init(userService: UserService, id: String) {
            let userWorkout = userService.insertNewUserWorkout()
            userWorkout.id = id
            userWorkout.date = Date()
            userWorkout.duration = 0.0
            self.init(userService: userService, userWorkout: userWorkout)
        }

        open func date(_ date: Date) -> Self {
            userWorkout.date = date
            return self
        }

        open func duration(_ duration: Double) -> Self {
            userWorkout.duration = duration
            return self
        }

        open func category(_ category: String) -> Self {
            userWorkout.category = category
            return self
        }

        open func category(_ category: WorkoutCategory) -> Self {
            userWorkout.category = category.rawValue
            return self
        }

    }

    open class UpdateUserWorkoutBuilder {

        let userService: UserService
        var userWorkout: UserWorkout
        var workoutInfos: NSMutableOrderedSet

        init(userService: UserService, userWorkout: UserWorkout) {
            self.userService = userService
            self.userWorkout = userWorkout
            self.workoutInfos = userWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        }

        open func addToDuration(_ duration: Double) -> Self {
            userWorkout.duration += duration
            return self
        }

        open func done(_ done: Bool) -> Self {
            userWorkout.done = done
            return self
        }

        open func addWorkout(_ workout: WorkoutProtocol?) -> Self {
            return addWorkout(workout?.name())
        }

        open func addWorkout(_ workoutName: String?) -> Self {
            if let name = workoutName {
                // this is aweful but I can't yet get the Equatable to work with WorkoutInfo.
                for w in workoutInfos {
                    if (w as AnyObject).name == workoutName {
                        return self
                    }
                }

                let workoutInfo = userService.insertNewWorkoutInfo()
                workoutInfo.name = name
                workoutInfo.date = Date()
                workoutInfos.add(workoutInfo)
                userWorkout.workouts = workoutInfos.copy() as! NSOrderedSet
            }
            return self
        }

        open func updateDuration(_ workoutName: String, duration: Double) -> Self {
            workoutInfos.enumerateObjects( { (elem, idx, stop) -> Void in
                let workoutInfo = elem as! WorkoutInfo
                if workoutInfo.name == workoutName {
                    workoutInfo.duration = duration
                    stop.initialize(to: true)
                }
            })
            return self
        }

        open func save() -> UserWorkout {
            userService.saveContext()
            return userWorkout
        }
        
    }
    
}
