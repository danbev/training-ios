//
//  WorkoutService.swift
//  FHR
//
//  Created by Daniel Bevenius on 08/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class WorkoutService {

    private let workoutEntityName = "Workout"
    private let userWorkoutEntityName = "UserWorkout"
    private let repsEntityName = "RepsWorkout"
    private let durationEntityName = "DurationWorkout"
    private let intervalEntityName = "IntervalWorkout"
    private var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func addRepsWorkout(name: String, desc: String, reps: Int, categories: Category...) -> RepsWorkout {
        let workout = newWorkoutEntity(name, desc: desc, categories: categories)
        let repsWorkoutEntity = NSEntityDescription.entityForName(repsEntityName, inManagedObjectContext: context)
        let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.repititions = reps
        repsWorkout.parent = workout
        saveContext()
        return repsWorkout
    }

    public func addDurationWorkout(name: String, desc: String, duration: Int, categories: Category...) -> DurationWorkout {
        let workout = newWorkoutEntity(name, desc: desc, categories: categories)
        let durationWorkoutEntity = NSEntityDescription.entityForName(durationEntityName, inManagedObjectContext: context)
        let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.duration = duration
        durationWorkout.parent = workout
        saveContext()
        return durationWorkout
    }

    public func addIntervalWorkout(name: String, desc: String, work: DurationWorkout, rest: DurationWorkout, categories: Category...) -> IntervalWorkout {
        let workout = newWorkoutEntity(name, desc: desc, categories: categories)
        let intervalWorkoutEntity = NSEntityDescription.entityForName(intervalEntityName, inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkout(entity: intervalWorkoutEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.work = work
        intervalWorkout.rest = rest
        intervalWorkout.parent = workout
        saveContext()
        return intervalWorkout
    }

    public func saveUserWorkout(id: String, category: Category, workout: Workout) -> UserWorkout {
        let userWorkoutEntity = NSEntityDescription.entityForName(userWorkoutEntityName, inManagedObjectContext: context)
        let userWorkout = UserWorkout(entity: userWorkoutEntity!, insertIntoManagedObjectContext: context)
        userWorkout.id = id
        userWorkout.category = category.rawValue
        userWorkout.done = false
        userWorkout.date = NSDate()
        workout.userWorkout = userWorkout
        saveContext()
        return userWorkout
    }

    public func updateUserWorkout(id: String, optionalWorkout: Workout?, done: Bool = false) -> Optional<UserWorkout> {
        let fetchRequest = NSFetchRequest(entityName: userWorkoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"id == %@", id)
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [UserWorkout]?
        if let results = fetchedResults {
            let userWorkout = results[0]
            userWorkout.done = done
            if let workout = optionalWorkout {
                workout.userWorkout = userWorkout
            }
            saveContext()
            return userWorkout
        } else {
            println("Could not update \(error), \(error!.userInfo)")
            return nil
        }
    }

    private func getDate() -> (year: Int, month: Int, day: Int) {
        let date = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components(.CalendarUnitWeekday, fromDate: date)
        return (components.year, components.month, components.day)
    }

    public func fetchUserWorkouts() -> Optional<[UserWorkout]> {
        let rw: [UserWorkout]? = fetchWorkouts(userWorkoutEntityName);
        return rw
    }

    public func fetchRepsWorkouts() -> Optional<[RepsWorkout]> {
        let rw: [RepsWorkout]? = fetchWorkouts(repsEntityName);
        return rw
    }

    public func fetchDurationWorkouts() -> Optional<[DurationWorkout]> {
        let dw: [DurationWorkout]? = fetchWorkouts(durationEntityName);
        return dw;
    }

    public func fetchIntervalWorkouts() -> Optional<[IntervalWorkout]> {
        let iw: [IntervalWorkout]? = fetchWorkouts(intervalEntityName);
        return iw;
    }

    public func fetchWorkout(name: String) -> Optional<Workout> {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"modelName == %@", name)
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func fetchWarmup() -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "modelCategories contains %@", "Warmup")
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchWarmup(userWorkout: UserWorkout) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "modelCategories contains %@", "Warmup")
        var error: NSError?
        let optionalIds = context.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObjectID]?
        var exludedWorkouts = Set<Workout>()
        for w in userWorkout.workouts {
            exludedWorkouts.insert(w as! Workout)
        }
        if var ids = optionalIds {
            return randomWorkout(&ids, excludedWorkouts: exludedWorkouts)
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return nil
    }

    private func randomWorkout(inout objectIds: [NSManagedObjectID], excludedWorkouts: Set<Workout>) -> Workout? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        var error: NSError?
        let optionalWorkout: Workout? = context.existingObjectWithID(objectId, error: &error) as! Workout?
        if let workout = optionalWorkout {
            var doneLastWorkout = false;
            for performedWorkout in excludedWorkouts {
                //println("\(performedWorkout.modelWorkoutName) == \(workout.modelWorkoutName)")
                if performedWorkout.modelWorkoutName == workout.modelWorkoutName {
                    doneLastWorkout = true;
                    break
                }
            }
            if doneLastWorkout {
                objectIds.removeAtIndex(index)
                if objectIds.count >= 1 {
                    return randomWorkout(&objectIds, excludedWorkouts: excludedWorkouts)
                } else {
                    return nil
                }
            } else {
                //println("workout \(workout.modelName) was not done in the last workout session so lets do it")
                return workout
            }
        } else {
            println("Could get a random workout \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchLatestUserWorkout() -> UserWorkout? {
        let fetchRequest = NSFetchRequest(entityName: userWorkoutEntityName)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [UserWorkout]?
        if let results = fetchedResults {
            if results.count == 0 {
                return nil
            } else {
                return results[0]
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchWorkout(category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "modelCategories contains %@", category)
        var error: NSError?
        let optionalIds = context.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObjectID]?
        var excludedWorkouts = Set<Workout>()
        for w in currentUserWorkout.workouts {
            excludedWorkouts.insert(w as! Workout)
        }
        if let last = lastUserWorkout {
            for w in last.workouts {
                excludedWorkouts.insert(w as! Workout)
            }
        }
        if var ids = optionalIds {
            if ids.count > 0 {
                return randomWorkout(&ids, excludedWorkouts: excludedWorkouts)
            } else {
                println("No ids!!!")
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return nil
    }

    public func loadDataIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        var error: NSError? = nil
        let results = context.countForFetchRequest(fetchRequest, error: &error)
        if (results == 0) {
            var fetchError: NSError? = nil
            importSeedData()
        }
    }

    private func importSeedData() {
        var error: NSError? = nil
        let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL!)!
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as! NSDictionary?
        // store workouts by name so we can back reference them.
        println("Import seed data...")
        var workouts = [String: WorkoutContainer]()
        if let json = jsonDict {
            //let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
            let workoutDict = jsonDict!.valueForKeyPath("workouts") as! NSDictionary
            let workoutsArray = workoutDict.valueForKeyPath("workout") as! NSArray
            for jsonDictionary in workoutsArray {
                let workout = WorkoutContainer(name: jsonDictionary["name"] as! String!,
                    desc: jsonDictionary["desc"] as! String!,
                    language: jsonDictionary["language"] as! String!,
                    image: UIImagePNGRepresentation(UIImage(named:jsonDictionary["image"] as! String!)))
                workouts[workout.name] = workout
                /*
                let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
                workout.modelName = jsonDictionary["name"] as! String!
                workout.modelDescription = jsonDictionary["desc"] as! String!
                workout.modelLanguage = jsonDictionary["language"] as! String!
                let imageName = jsonDictionary["image"] as! String
                let image = UIImage(named:imageName)
                let photoData = UIImagePNGRepresentation(image)
                workout.modelImage = photoData
                workouts[workout.modelName] = workout
                */
            }
            let repsWorkoutEntity = NSEntityDescription.entityForName(self.repsEntityName, inManagedObjectContext: context)
            let repsbasedArray = workoutDict.valueForKeyPath("repbased") as! NSArray
            for jsonDictionary in repsbasedArray {
                let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                repsWorkout.modelWorkoutName = jsonDictionary["name"] as! String!
                repsWorkout.modelName = workout.name
                repsWorkout.modelDescription = workout.desc
                repsWorkout.modelImage = workout.image
                repsWorkout.modelLanguage = workout.language

                repsWorkout.repititions = jsonDictionary["reps"] as! NSNumber!
                repsWorkout.approx = jsonDictionary["approx"] as! NSNumber!
                repsWorkout.modelCategories = jsonDictionary["categories"] as! String!
                repsWorkout.modelRestTime = jsonDictionary["rest"] as! Double!
                repsWorkout.modelType = Type.Reps.rawValue
            }

            let durationWorkoutEntity = NSEntityDescription.entityForName(self.durationEntityName, inManagedObjectContext: context)
            let timebasedArray = workoutDict.valueForKeyPath("timebased") as! NSArray
            for jsonDictionary in timebasedArray {
                let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                durationWorkout.modelWorkoutName = jsonDictionary["name"] as! String!
                durationWorkout.modelName = workout.name
                durationWorkout.modelDescription = workout.desc
                durationWorkout.modelImage = workout.image
                durationWorkout.modelLanguage = workout.language

                durationWorkout.duration = jsonDictionary["duration"] as! NSNumber!
                durationWorkout.modelCategories = jsonDictionary["categories"] as! String!
                durationWorkout.modelType = Type.Timed.rawValue
                durationWorkout.modelRestTime = jsonDictionary["rest"] as! Double!
            }
            saveContext()
        } else {
            println("could not parse json data.")
        }
    }

    private struct WorkoutContainer {
        var name: String
        var desc: String
        var language: String
        var image: NSData

    }

    private func saveContext() {
        var error: NSError?
        if !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }

    private func newWorkoutEntity(name: String, desc: String, categories: [Category]) -> Workout {
        let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.modelName = name
        workout.modelDescription = desc
        workout.modelCategories = Category.asCsvString(categories)
        return workout;
    }

    private func fetchWorkouts<T:AnyObject>(entityName: String) -> Optional<[T]> {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [T]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public class func random (#lower: Int , upper: Int) -> Int {
        let l:UInt32 = UInt32(lower)
        let r:UInt32 = UInt32(upper - lower + 1)
        return Int(l + r)
    }

}
