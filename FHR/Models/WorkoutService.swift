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
    private static let repsEntityName = "RepsWorkout"
    private let durationEntityName = "DurationWorkout"
    private let intervalEntityName = "IntervalWorkout"
    private let prebensEntityName = "PrebensWorkout"
    private var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func saveRepsWorkout(repsBuilder: RepsBuilder) -> RepsWorkout {
        let repsWorkout = repsBuilder.build()
        saveContext()
        return repsWorkout
    }

    public func saveDurationWorkout(name: String, desc: String, duration: Int, categories: WorkoutCategory...) -> DurationWorkout {
        let workout = newWorkoutEntity(name, desc: desc, categories: categories)
        let durationWorkoutEntity = NSEntityDescription.entityForName(durationEntityName, inManagedObjectContext: context)
        let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.duration = duration
        durationWorkout.workoutDescription = desc
        durationWorkout.name = name
        durationWorkout.workoutName = name
        durationWorkout.categories = WorkoutCategory.asCsvString(categories)
        saveContext()
        return durationWorkout
    }

    public func addIntervalWorkout(name: String, desc: String, work: DurationWorkout, rest: DurationWorkout, categories: WorkoutCategory...) -> IntervalWorkout {
        let workout = newWorkoutEntity(name, desc: desc, categories: categories)
        let intervalWorkoutEntity = NSEntityDescription.entityForName(intervalEntityName, inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkout(entity: intervalWorkoutEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.work = work
        intervalWorkout.rest = rest
        intervalWorkout.name = name
        intervalWorkout.workoutName = name
        intervalWorkout.workoutDescription = desc
        saveContext()
        return intervalWorkout
    }

    public func newUserWorkout(lastUserWorkout: UserWorkout?, settings: Settings) -> UserWorkout? {
        let id = NSUUID().UUIDString
        if settings.ignoredCategories.contains(WorkoutCategory.Warmup) {
            let category = lastUserWorkout != nil  ? lastUserWorkout!.category : WorkoutCategory.Warmup.next(settings.ignoredCategories).rawValue
            let userWorkout = saveUserWorkout(id, category: WorkoutCategory.Warmup.next(settings.ignoredCategories), workout: nil)
            let workout = fetchWorkout(category, currentUserWorkout: userWorkout, lastUserWorkout: lastUserWorkout, weights: settings.weights, dryGround: settings.dryGround)
            return updateUserWorkout(id, optionalWorkout: workout, workoutTime: 0.0, done: false)
        }
        if let lastWorkout = lastUserWorkout {
            if let warmup = fetchWarmup(lastWorkout) {
                return saveUserWorkout(id, category: WorkoutCategory(rawValue: lastWorkout.category)!.next(settings.ignoredCategories), workout: warmup)
            }
        } else {
            if let warmup = fetchWarmup() {
                return saveUserWorkout(id, category: WorkoutCategory.Warmup.next(settings.ignoredCategories), workout: warmup)
            }
        }
        return nil
    }

    public func saveUserWorkout(id: String, category: WorkoutCategory, workout: Workout?) -> UserWorkout {
        let userWorkoutEntity = NSEntityDescription.entityForName(userWorkoutEntityName, inManagedObjectContext: context)
        let userWorkout = UserWorkout(entity: userWorkoutEntity!, insertIntoManagedObjectContext: context)
        userWorkout.id = id
        userWorkout.category = category.rawValue
        userWorkout.done = false
        userWorkout.date = NSDate()
        if let w = workout {
            userWorkout.workouts.addObject(w)
            w.userWorkout = userWorkout
        }
        saveContext()
        return userWorkout
    }

    public func updateUserWorkout(id: String, optionalWorkout: Workout?, workoutTime: Double, done: Bool = false) -> Optional<UserWorkout> {
        let fetchRequest = NSFetchRequest(entityName: userWorkoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"id == %@", id)
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [UserWorkout]?
        if let results = fetchedResults {
            let userWorkout = results[0]
            userWorkout.done = done
            userWorkout.duration = userWorkout.duration + workoutTime
            if let workout = optionalWorkout {
                workout.userWorkout = userWorkout
                userWorkout.workouts.addObject(workout)
            }
            saveContext()
            return userWorkout
        } else {
            debugPrintln("Could not update \(error), \(error!.userInfo)")
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
        let rw: [RepsWorkout]? = fetchWorkouts(WorkoutService.repsEntityName);
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

    public func fetchPrebensWorkouts() -> Optional<[PrebensWorkout]> {
        let iw: [PrebensWorkout]? = fetchWorkouts(prebensEntityName);
        return iw;
    }

    public func fetchWorkout(name: String) -> Optional<Workout> {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func fetchWarmup() -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchWarmup(userWorkout: UserWorkout) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        var error: NSError?
        let optionalIds = context.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObjectID]?
        var exludedWorkouts = Set<Workout>()
        for w in userWorkout.workouts {
            exludedWorkouts.insert(w as! Workout)
        }
        if var ids = optionalIds {
            return randomWorkout(&ids, excludedWorkouts: exludedWorkouts)
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
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
                if performedWorkout.workoutName == workout.workoutName {
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
                return workout
            }
        } else {
            debugPrintln("Could not get a random workout \(error), \(error!.userInfo)")
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
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchWorkout(category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?, weights: Bool, dryGround: Bool) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND weights = %@", category, weights)
        if !weights && !dryGround {
            fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND weights = true AND dryGround = true", category)
        } else if !weights {
            fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND weights = false", category)
        } else if !dryGround {
            fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND dryGround = false", category)
        } else {
            fetchRequest.predicate = NSPredicate(format: "categories contains %@", category)
        }
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
                debugPrintln("No ids!!!")
            }
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
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
        debugPrintln("Import seed data...")
        var workouts = [String: WorkoutContainer]()
        if let json = jsonDict {
            let workoutDict = jsonDict!.valueForKeyPath("workouts") as! NSDictionary
            let workoutsArray = workoutDict.valueForKeyPath("workout") as! NSArray
            for jsonDictionary in workoutsArray {
                let workout = WorkoutContainer(name: jsonDictionary["name"] as! String!,
                    desc: jsonDictionary["desc"] as! String!,
                    language: jsonDictionary["language"] as! String!,
                    videoUrl: jsonDictionary["videoUrl"] as! String!,
                    weights: jsonDictionary["weights"] as! Bool!,
                    dryGround: jsonDictionary["dryGround"] as! Bool!)
                workouts[workout.name] = workout
            }
            let repsWorkoutEntity = NSEntityDescription.entityForName(WorkoutService.repsEntityName, inManagedObjectContext: context)
            let repsbasedArray = workoutDict.valueForKeyPath("repbased") as! NSArray
            for jsonDictionary in repsbasedArray {
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                let repsWorkout = RepsBuilder(context: context)
                    .name(workout.name)
                    .workoutName(jsonDictionary["name"] as! String)
                    .description(workout.desc)
                    .reps(jsonDictionary["reps"] as! NSNumber)
                    .videoUrl(workout.videoUrl)
                    .language(workout.language)
                    .weights(workout.weights)
                    .dryGround(workout.dryGround)
                    .approx(jsonDictionary["approx"] as! NSNumber)
                    .postRestTime(jsonDictionary["rest"] as! NSNumber)
                    .categories(jsonDictionary["categories"] as! String)
                    .build()
            }

            let durationWorkoutEntity = NSEntityDescription.entityForName(self.durationEntityName, inManagedObjectContext: context)
            let timebasedArray = workoutDict.valueForKeyPath("timebased") as! NSArray
            for jsonDictionary in timebasedArray {
                let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                durationWorkout.workoutName = jsonDictionary["name"] as! String!
                durationWorkout.name = workout.name
                durationWorkout.workoutDescription = workout.desc
                durationWorkout.videoUrl = workout.videoUrl
                durationWorkout.language = workout.language
                durationWorkout.weights = workout.weights
                durationWorkout.dryGround = workout.dryGround

                durationWorkout.duration = jsonDictionary["duration"] as! NSNumber!
                durationWorkout.categories = jsonDictionary["categories"] as! String!
                durationWorkout.type = WorkoutType.Timed.rawValue
                durationWorkout.restTime = jsonDictionary["rest"] as! Double!
            }
            let prebensArray = workoutDict.valueForKeyPath("prebensbased") as! NSArray
            for jsonDictionary in prebensArray {
                let prebensWorkoutEntity = NSEntityDescription.entityForName(self.prebensEntityName, inManagedObjectContext: context)

                let prebensWorkout = PrebensWorkout(entity: prebensWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                prebensWorkout.workoutName = jsonDictionary["name"] as! String
                prebensWorkout.type = WorkoutType.Prebens.rawValue
                prebensWorkout.name = workout.name
                prebensWorkout.workoutDescription = workout.desc
                prebensWorkout.language = workout.language
                prebensWorkout.weights = workout.weights
                prebensWorkout.dryGround = workout.dryGround
                prebensWorkout.categories = jsonDictionary["categories"] as! String!

                let tasks = jsonDictionary.valueForKeyPath("workouts") as! NSArray
                var prebensWorkouts = prebensWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
                for (i, w) in enumerate(tasks) {
                    let workout = workouts[w["workout"] as! String!]!
                    let repsWorkout = reps(w["reps"] as! NSNumber)
                        .name(workout.name)
                        .workoutName(w["name"] as! String)
                        .description(workout.desc)
                        .videoUrl(workout.videoUrl)
                        .language(workout.language)
                        .weights(workout.weights)
                        .dryGround(workout.dryGround)
                        .approx(w["approx"] as! NSNumber)
                        .postRestTime(w["rest"] as! NSNumber)
                        .categories(w["categories"] as! String)
                        .build()
                    prebensWorkouts.addObject(repsWorkout)
                    prebensWorkout.workouts = prebensWorkouts.copy() as! NSOrderedSet
                    saveContext()
                }
            }
            let intervalArray = workoutDict.valueForKeyPath("intervalbased") as! NSArray
            for jsonDictionary in intervalArray {
                let intervalWorkoutEntity = NSEntityDescription.entityForName(intervalEntityName, inManagedObjectContext: context)
                let intervalWorkout = IntervalWorkout(entity: intervalWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                intervalWorkout.workoutName = jsonDictionary["name"] as! String
                intervalWorkout.type = WorkoutType.Interval.rawValue
                intervalWorkout.name = workout.name
                intervalWorkout.intervals = jsonDictionary["intervals"] as! Int
                intervalWorkout.workoutDescription = workout.desc
                intervalWorkout.language = workout.language
                intervalWorkout.weights = workout.weights
                intervalWorkout.dryGround = workout.dryGround
                intervalWorkout.categories = jsonDictionary["categories"] as! String!
                let work = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
                let workJson = jsonDictionary["mainWorkout"] as! NSDictionary
                let workWorkout = workouts[workJson["workout"] as! String]!
                work.name = workWorkout.name
                work.workoutName = workJson["name"] as! String
                work.duration = workJson["duration"] as! Double
                work.restTime = workJson["rest"] as! Int
                work.categories = workJson["categories"] as! String!
                work.workoutDescription = workout.desc
                work.videoUrl = workout.videoUrl
                work.language = workout.language
                work.weights = workout.weights
                work.dryGround = workout.dryGround
                intervalWorkout.work = work

                let rest = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
                let restJson = jsonDictionary["restWorkout"] as! NSDictionary
                let restWorkout = workouts[restJson["workout"] as! String]!
                rest.name = restWorkout.name
                rest.workoutName = restJson["name"] as! String
                rest.duration = restJson["duration"] as! Double
                rest.restTime = restJson["rest"] as! Int
                rest.categories = restJson["categories"] as! String!
                rest.workoutDescription = restWorkout.desc
                rest.videoUrl = restWorkout.videoUrl
                rest.language = restWorkout.language
                rest.weights = restWorkout.weights
                rest.dryGround = restWorkout.dryGround
                intervalWorkout.rest = rest
                saveContext()
            }
            saveContext()
        } else {
            debugPrintln("could not parse json data.")
        }
    }

    private struct WorkoutContainer {
        var name: String
        var desc: String
        var language: String
        var videoUrl: String
        var weights: Bool
        var dryGround: Bool
    }

    private func saveContext() {
        var error: NSError?
        if !context.save(&error) {
            debugPrintln("Could not save \(error), \(error?.userInfo)")
        }
    }

    private func newWorkoutEntity(name: String, desc: String, categories: [WorkoutCategory]) -> Workout {
        let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.name = name
        workout.workoutDescription = desc
        workout.categories = WorkoutCategory.asCsvString(categories)
        return workout;
    }

    private func fetchWorkouts<T:AnyObject>(entityName: String) -> Optional<[T]> {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as! [T]?
        if let results = fetchedResults {
            return results
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public class func random (#lower: Int , upper: Int) -> Int {
        let l:UInt32 = UInt32(lower)
        let r:UInt32 = UInt32(upper - lower + 1)
        return Int(l + r)
    }

    public func reps(reps: NSNumber) -> RepsBuilder {
        return RepsBuilder(context: context).reps(reps)
    }

}

public class RepsBuilder {

    let repsWorkout: RepsWorkout

    init(context: NSManagedObjectContext) {
        let repsWorkoutEntity = NSEntityDescription.entityForName(WorkoutService.repsEntityName, inManagedObjectContext: context)
        repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.type = WorkoutType.Reps.rawValue
    }

    public func name(name: String) -> RepsBuilder {
        repsWorkout.name = name
        return self
    }

    public func workoutName(name: String) -> RepsBuilder {
        repsWorkout.workoutName = name
        return self
    }

    public func description(description: String) -> RepsBuilder {
        repsWorkout.workoutDescription = description
        return self
    }

    public func reps(reps: NSNumber) -> RepsBuilder {
        repsWorkout.repititions = reps
        return self
    }

    public func videoUrl(videoUrl: String?) -> RepsBuilder {
        repsWorkout.videoUrl = videoUrl
        return self
    }

    public func language(language: String) -> RepsBuilder {
        repsWorkout.language = language
        return self
    }

    public func weights(weights: Bool) -> RepsBuilder {
        repsWorkout.weights = weights
        return self
    }

    public func dryGround(dryGround: Bool) -> RepsBuilder {
        repsWorkout.dryGround = dryGround
        return self
    }

    public func approx(approx: NSNumber) -> RepsBuilder {
        repsWorkout.approx = approx
        return self
    }

    public func postRestTime(restTime: NSNumber) -> RepsBuilder {
        repsWorkout.restTime = restTime
        return self
    }

    public func categories(categories: WorkoutCategory...) -> RepsBuilder {
        repsWorkout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    public func categories(categories: String) -> RepsBuilder {
        repsWorkout.categories = categories
        return self
    }

    public func build() -> RepsWorkout {
        return repsWorkout
    }
}

