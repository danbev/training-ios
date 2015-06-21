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

    private static let repsEntityName = "RepsWorkout"
    private static let durationEntityName = "DurationWorkout"
    private static let intervalEntityName = "IntervalWorkout"
    private static let prebensEntityName = "PrebensWorkout"
    private let workoutEntityName = "Workout"
    private let userWorkoutEntityName = "UserWorkout"
    private var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func saveWorkout<T: Workout>(workoutBuilder: WorkoutBuilder<T>) -> T {
        let workout = workoutBuilder.build()
        saveContext()
        return workout
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
        let dw: [DurationWorkout]? = fetchWorkouts(WorkoutService.durationEntityName);
        return dw;
    }

    public func fetchIntervalWorkouts() -> Optional<[IntervalWorkout]> {
        let iw: [IntervalWorkout]? = fetchWorkouts(WorkoutService.intervalEntityName);
        return iw;
    }

    public func fetchPrebensWorkouts() -> Optional<[PrebensWorkout]> {
        let iw: [PrebensWorkout]? = fetchWorkouts(WorkoutService.prebensEntityName);
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
            let repsbasedArray = workoutDict.valueForKeyPath("repbased") as! NSArray
            for jsonDictionary in repsbasedArray {
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                let repsWorkout = reps(jsonDictionary["reps"] as! NSNumber)
                    .name(workout.name)
                    .workoutName(jsonDictionary["name"] as! String)
                    .description(workout.desc)
                    .videoUrl(workout.videoUrl)
                    .language(workout.language)
                    .weights(workout.weights)
                    .dryGround(workout.dryGround)
                    .approx(jsonDictionary["approx"] as! NSNumber)
                    .postRestTime(jsonDictionary["rest"] as! NSNumber)
                    .categories(jsonDictionary["categories"] as! String)
                    .build()
            }

            let timebasedArray = workoutDict.valueForKeyPath("timebased") as! NSArray
            for jsonDictionary in timebasedArray {
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                let durationWorkout = duration(jsonDictionary["duration"] as! NSNumber!)
                    .name(workout.name)
                    .workoutName(jsonDictionary["name"] as! String!)
                    .description(workout.desc)
                    .videoUrl(workout.videoUrl)
                    .language(workout.language)
                    .weights(workout.weights)
                    .dryGround(workout.dryGround)
                    .postRestTime(jsonDictionary["rest"] as! NSNumber)
                    .categories(jsonDictionary["categories"] as! String)
                    .build()
            }
            let prebensArray = workoutDict.valueForKeyPath("prebensbased") as! NSArray
            for jsonDictionary in prebensArray {
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                let prebensWorkout = prebens()
                    .name(workout.name)
                    .workoutName(jsonDictionary["name"] as! String)
                    .description(workout.desc)
                    .language(workout.language)
                    .weights(workout.weights)
                    .dryGround(workout.dryGround)
                    .categories(jsonDictionary["categories"] as! String)

                let tasks = jsonDictionary.valueForKeyPath("workouts") as! NSArray
                for (i, w) in enumerate(tasks) {
                    let workout = workouts[w["workout"] as! String!]!
                    prebensWorkout.workItem(reps(w["reps"] as! NSNumber)
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
                        .build())
                    saveContext()
                }
            }
            let intervalArray = workoutDict.valueForKeyPath("intervalbased") as! NSArray
            for jsonDictionary in intervalArray {
                let workout = workouts[jsonDictionary["workout"] as! String!]!
                let workJson = jsonDictionary["mainWorkout"] as! NSDictionary
                let workWorkout = workouts[workJson["workout"] as! String]!
                let restJson = jsonDictionary["restWorkout"] as! NSDictionary
                let restWorkout = workouts[restJson["workout"] as! String]!
                let work = duration(workJson["duration"] as! NSNumber!)
                    .name(workWorkout.name)
                    .workoutName(workJson["name"] as! String!)
                    .description(workWorkout.desc)
                    .videoUrl(workWorkout.videoUrl)
                    .language(workWorkout.language)
                    .weights(workWorkout.weights)
                    .dryGround(workWorkout.dryGround)
                    .postRestTime(workJson["rest"] as! NSNumber)
                    .categories(workJson["categories"] as! String)
                    .build()
                let rest = duration(restJson["duration"] as! NSNumber!)
                    .name(restWorkout.name)
                    .workoutName(restJson["name"] as! String!)
                    .description(restWorkout.desc)
                    .videoUrl(restWorkout.videoUrl)
                    .language(restWorkout.language)
                    .weights(restWorkout.weights)
                    .dryGround(restWorkout.dryGround)
                    .postRestTime(restJson["rest"] as! NSNumber)
                    .categories(restJson["categories"] as! String)
                    .build()
                let intervalWorkout = interval(work, rest: rest)
                    .name(workout.name)
                    .workoutName(jsonDictionary["name"] as! String)
                    .intervals(jsonDictionary["intervals"] as! Int)
                    .description(workout.desc)
                    .language(workout.language)
                    .weights(workout.weights)
                    .dryGround(workout.dryGround)
                    .categories(jsonDictionary["categories"] as! String)
                    .build()
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

    public func reps(reps: NSNumber) -> RepsBuilder<RepsWorkout> {
        return RepsBuilder(context: context).reps(reps)
    }

    public func duration(duration: NSNumber) -> DurationBuilder<DurationWorkout> {
        return DurationBuilder(context: context).duration(duration)
    }

    public func interval(work: DurationWorkout, rest: DurationWorkout) -> IntervalBuilder<IntervalWorkout> {
        return IntervalBuilder(context: context).work(work).rest(rest)
    }

    public func prebens() -> PrebensBuilder<PrebensWorkout> {
        return PrebensBuilder(context: context)
    }

}

public class WorkoutBuilder<T: Workout> {

    let workout: T

    init(workout: T) {
        self.workout = workout
    }

    public func name(name: String) -> Self {
        workout.name = name
        return self
    }

    public func workoutName(name: String) -> Self {
        workout.workoutName = name
        return self
    }

    public func description(description: String) -> Self {
        workout.workoutDescription = description
        return self
    }

    public func videoUrl(videoUrl: String?) -> Self {
        workout.videoUrl = videoUrl
        return self
    }

    public func language(language: String) -> Self {
        workout.language = language
        return self
    }

    public func weights(weights: Bool) -> Self {
        workout.weights = weights
        return self
    }

    public func dryGround(dryGround: Bool) -> Self {
        workout.dryGround = dryGround
        return self
    }

    public func postRestTime(restTime: NSNumber) -> Self {
        workout.restTime = restTime
        return self
    }

    public func categories(categories: WorkoutCategory...) -> Self {
        workout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    public func categories(categories: String) -> Self {
        workout.categories = categories
        return self
    }

    public func build() -> T {
        return workout
    }
}

public class RepsBuilder<T: RepsWorkout>: WorkoutBuilder<RepsWorkout> {

    let repsWorkout: RepsWorkout

    init(context: NSManagedObjectContext) {
        let repsWorkoutEntity = NSEntityDescription.entityForName(WorkoutService.repsEntityName, inManagedObjectContext: context)
        repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.type = WorkoutType.Reps.rawValue
        super.init(workout: repsWorkout)
    }

    public func reps(reps: NSNumber) -> RepsBuilder {
        repsWorkout.repititions = reps
        return self
    }

    public func approx(approx: NSNumber) -> RepsBuilder {
        repsWorkout.approx = approx
        return self
    }

}

public class DurationBuilder<T: DurationWorkout>: WorkoutBuilder<DurationWorkout> {

    let durationWorkout: DurationWorkout

    init(context: NSManagedObjectContext) {
        let durationEntity = NSEntityDescription.entityForName(WorkoutService.durationEntityName, inManagedObjectContext: context)
        durationWorkout = DurationWorkout(entity: durationEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.type = WorkoutType.Timed.rawValue
        super.init(workout: durationWorkout)
    }

    public func duration(duration: NSNumber) -> DurationBuilder {
        durationWorkout.duration = duration
        return self
    }

}

public class IntervalBuilder<T: IntervalWorkout>: WorkoutBuilder<IntervalWorkout> {

    let intervalWorkout: IntervalWorkout

    init(context: NSManagedObjectContext) {
        let intervalEntity = NSEntityDescription.entityForName(WorkoutService.intervalEntityName, inManagedObjectContext: context)
        intervalWorkout = IntervalWorkout(entity: intervalEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.type = WorkoutType.Interval.rawValue
        super.init(workout: intervalWorkout)
    }

    public func work(work: DurationWorkout) -> IntervalBuilder {
        intervalWorkout.work = work
        return self
    }

    public func rest(rest: DurationWorkout) -> IntervalBuilder {
        intervalWorkout.rest = rest
        return self
    }

    public func intervals(intervals: Int) -> IntervalBuilder {
        intervalWorkout.intervals = intervals
        return self
    }

}

public class PrebensBuilder<T: PrebensWorkout>: WorkoutBuilder<PrebensWorkout> {

    let prebensWorkout: PrebensWorkout
    var prebensWorkouts: NSMutableOrderedSet

    init(context: NSManagedObjectContext) {
        let prebensEntity = NSEntityDescription.entityForName(WorkoutService.prebensEntityName, inManagedObjectContext: context)
        prebensWorkout = PrebensWorkout(entity: prebensEntity!, insertIntoManagedObjectContext: context)
        prebensWorkout.type = WorkoutType.Prebens.rawValue
        prebensWorkouts = prebensWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        super.init(workout: prebensWorkout)
    }

    public func workItem(repsWorkout: RepsWorkout) -> PrebensBuilder {
        prebensWorkouts.addObject(repsWorkout)
        prebensWorkout.workouts = prebensWorkouts.copy() as! NSOrderedSet
        return self
    }

}


