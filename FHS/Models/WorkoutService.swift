//
//  WorkoutService.swift
//  FHR
//
//  Created by Daniel Bevenius on 08/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
//import UIKit
import CoreData

public class WorkoutService {

    private static let repsEntityName = "RepsWorkout"
    private static let durationEntityName = "DurationWorkout"
    private static let intervalEntityName = "IntervalWorkout"
    private static let prebensEntityName = "PrebensWorkout"
    private let workoutEntityName = "Workout"
    private var context: NSManagedObjectContext
    private let userService: UserService
    private let coreDataStack: CoreDataStack

    public init(coreDataStack: CoreDataStack, userService: UserService) {
        self.coreDataStack = coreDataStack
        context = coreDataStack.context
        self.userService = userService
    }

    public func getUserService() -> UserService {
        return userService
    }

    public func stores() -> [String] {
        return coreDataStack.storeNames
    }

    public func newUserWorkout(lastUserWorkout: UserWorkout?, settings: Settings) -> UserWorkout? {
        let id = NSUUID().UUIDString
        if settings.ignoredCategories.contains(WorkoutCategory.Warmup) {
            let category = lastUserWorkout != nil ? lastUserWorkout!.category : WorkoutCategory.Warmup.next(settings.ignoredCategories).rawValue
            let userWorkout = userService.newUserWorkout(id)
                .category(WorkoutCategory.Warmup.next(settings.ignoredCategories))
                .save()
            let workout = fetchWorkout(category, currentUserWorkout: userWorkout, lastUserWorkout: lastUserWorkout, weights: settings.weights, dryGround: settings.dryGround)
            return userService.updateUserWorkout(userWorkout).addWorkout(workout!.name).save()
        }

        if let lastWorkout = lastUserWorkout {
            if let warmup = fetchWarmupProtocol(lastWorkout) {
                return userService.newUserWorkout(id)
                    .category(WorkoutCategory(rawValue: lastWorkout.category)!.next(settings.ignoredCategories))
                    .addWorkout(warmup.name())
                    .save()
            }
        } else {
            if let warmup = fetchWarmupProtocol() {
                return userService.newUserWorkout(id).category(WorkoutCategory.Warmup.next(settings.ignoredCategories))
                    .addWorkout(warmup.name())
                    .save()
            }
        }
        return nil
    }

    private func getDate() -> (year: Int, month: Int, day: Int) {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components(.Weekday, fromDate: NSDate())
        return (components.year, components.month, components.day)
    }

    public func fetchRepsWorkouts() -> [RepsWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.repsEntityName))
    }

    public func fetchRepsWorkoutsDestinct() -> [String]? {
        return fetchWorkoutsDestinct(WorkoutService.repsEntityName)
    }

    public func fetchDurationWorkoutsDestinct() -> [String]? {
        return fetchWorkoutsDestinct(WorkoutService.durationEntityName)
    }

    public func fetchWorkoutsDestinct(entityName: String) -> [String]? {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.propertiesToFetch = ["name"]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: NSError?
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            var workoutNames = Set<String>()
            for var i = 0; i < results.count; i++ {
                if let dic = (results[i] as? [String : String]) {
                    if let name = dic["name"] {
                        workoutNames.insert(name)
                    }
                }
            }
            var a = Array(workoutNames)
            a.sortInPlace()
            return a
        } catch let error1 as NSError {
            error = error1
            debugPrint("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchDurationWorkouts() -> [DurationWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.durationEntityName))
    }

    public func fetchIntervalWorkouts() -> [IntervalWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.intervalEntityName))
    }

    public func fetchPrebensWorkouts() -> [PrebensWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.prebensEntityName))
    }

    public func fetchWorkoutProtocol(name: String) -> WorkoutProtocol? {
        if let managedWorkout = fetchWorkout(name) {
            return managedWorkoutToProtocol(managedWorkout)
        }
        return nil
    }

    public func managedWorkoutToProtocol(managedWorkout: WorkoutManagedObject) -> WorkoutProtocol {
        let _ = workoutFrom(managedWorkout)
        switch (WorkoutType(rawValue: managedWorkout.type)!) {
        case .Reps:
            return repsWorkoutFrom(managedWorkout as! RepsWorkoutManagedObject)
        case .Timed:
            return durationWorkoutFrom(managedWorkout as! DurationWorkoutManagedObject)
        case .Interval:
            return intervalWorkoutFrom(managedWorkout as! IntervalWorkoutManagedObject)
        case .Prebens:
            return prebensWorkoutFrom(managedWorkout as! PrebensWorkoutManagedObject)
        }
    }

    private func repsSetFrom(repsWorkouts: NSOrderedSet) -> [RepsWorkout] {
        var set = [RepsWorkout]()
        for w in repsWorkouts {
            set.append(repsWorkoutFrom(w as! RepsWorkoutManagedObject))
        }
        return set
    }

    private func intervalWorkoutFrom(managedIntervalWorkout: IntervalWorkoutManagedObject) -> IntervalWorkoutProtocol {
        return IntervalWorkout(workout: workoutFrom(managedIntervalWorkout),
            work: durationWorkoutFrom(managedIntervalWorkout.work),
            rest: durationWorkoutFrom(managedIntervalWorkout.rest),
            intervals: managedIntervalWorkout.intervals)
    }

    private func prebensWorkoutFrom(managedPrebensWorkout: PrebensWorkoutManagedObject) -> PrebensWorkoutProtocol {
        let workouts = managedPrebensWorkout.workouts
        return PrebensWorkout(workout: workoutFrom(managedPrebensWorkout), workouts: repsSetFrom(workouts))
    }

    private func repsWorkoutFrom(managedRepsWorkout: RepsWorkoutManagedObject) -> RepsWorkout {
        return RepsWorkout(workout: workoutFrom(managedRepsWorkout), reps: managedRepsWorkout.repititions, approx: managedRepsWorkout.approx)
    }

    private func durationWorkoutFrom(managedDurationWorkout: DurationWorkoutManagedObject) -> DurationWorkout {
        return DurationWorkout(workout: workoutFrom(managedDurationWorkout), duration: managedDurationWorkout.duration)
    }

    private func setWorkoutProperties(instance: WorkoutManagedObject, workoutProtocol: WorkoutProtocol) {
        instance.name = workoutProtocol.name()
        instance.workoutName = workoutProtocol.workoutName()
        instance.workoutDescription = workoutProtocol.workoutDescription()
        instance.language = workoutProtocol.language()
        instance.categories = workoutProtocol.categories()
        instance.videoUrl = workoutProtocol.videoUrl()
        instance.restTime = workoutProtocol.restTime()
        instance.weights = workoutProtocol.weights()
        instance.dryGround = workoutProtocol.dryGround()
    }

    private func toManagedDurationWorkout(durationProtocol: DurationWorkoutProtocol) -> DurationWorkoutManagedObject {
        let durationWorkout = newDurationWorkout()
        setWorkoutProperties(durationWorkout, workoutProtocol: durationProtocol)
        durationWorkout.duration = durationProtocol.duration()
        return durationWorkout
    }

    private func toManagedRepsWorkout(repsProtocol: RepsWorkoutProtocol) -> RepsWorkoutManagedObject {
        let repsWorkout = newRepsWorkout()
        setWorkoutProperties(repsWorkout, workoutProtocol: repsProtocol)
        repsWorkout.repititions = repsProtocol.repititions()
        repsWorkout.approx = repsProtocol.approx()
        return repsWorkout
    }

    public func workoutFrom(managedWorkout: WorkoutManagedObject) -> WorkoutProtocol {
        return Workout(name: managedWorkout.name,
            workoutName: managedWorkout.workoutName,
            workoutDescription: managedWorkout.workoutDescription,
            language: managedWorkout.language,
            categories: managedWorkout.categories,
            videoUrl: managedWorkout.videoUrl,
            restTime: managedWorkout.restTime,
            weights: managedWorkout.weights?.boolValue ?? false,
            dryGround: managedWorkout.dryGround?.boolValue ?? false)
    }

    private func fetchWorkout(name: String) -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    private func fetchWarmup() -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    public func fetchWarmupProtocol() -> WorkoutProtocol? {
        if let managedWorkout = fetchWarmup() {
            return managedWorkoutToProtocol(managedWorkout)
        }
        return nil
    }

    public func fetchWarmupProtocol(userWorkout: UserWorkout) -> WorkoutProtocol? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        do {
            let optionalIds = try self.context.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            var exludedWorkouts = Set<String>()
            for w in userWorkout.workouts {
                let workoutInfo = w as! WorkoutInfo
                exludedWorkouts.insert(workoutInfo.name)
            }
            if var ids = optionalIds {
                return randomWorkout2(&ids, excludedWorkouts: exludedWorkouts)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    private func fetchWarmup(userWorkout: UserWorkout) -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        do {
            let optionalIds = try context.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            var exludedWorkouts = Set<String>()
            for w in userWorkout.workouts {
                let workoutInfo = w as! WorkoutInfo
                exludedWorkouts.insert(workoutInfo.name)
            }
            if var ids = optionalIds {
                return randomWorkout(&ids, excludedWorkouts: exludedWorkouts)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    public func fetchLatestPerformed(name: String) -> WorkoutInfo? {
        return userService.fetchPerformedWorkoutInfo(name)
    }

    private func randomWorkout2(inout objectIds: [NSManagedObjectID], excludedWorkouts: Set<String>) -> WorkoutProtocol? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        do {
            if let workout = try context.existingObjectWithID(objectId) as? WorkoutManagedObject {
                var doneLastWorkout = false
                for performedWorkout in excludedWorkouts {
                    if performedWorkout == workout.name {
                        doneLastWorkout = true
                        break
                    }
                }
                if doneLastWorkout {
                    objectIds.removeAtIndex(index)
                    if objectIds.count >= 1 {
                        return randomWorkout2(&objectIds, excludedWorkouts: excludedWorkouts)
                    } else {
                        return nil
                    }
                } else {
                    return managedWorkoutToProtocol(workout)
                }
            }
        } catch let error as NSError {
            print("Could not get a random workout \(error), \(error.userInfo)")
        }
        return nil
    }

    private func randomWorkout(inout objectIds: [NSManagedObjectID], excludedWorkouts: Set<String>) -> WorkoutManagedObject? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        do {
            if let workout = try context.existingObjectWithID(objectId) as? WorkoutManagedObject {
                var doneLastWorkout = false
                for performedWorkout in excludedWorkouts {
                    if performedWorkout == workout.name {
                        doneLastWorkout = true
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
            }
        } catch let error as NSError {
            print("Could not get a random workout \(error), \(error.userInfo)")
        }
        return nil
    }

    public func fetchLatestUserWorkout() -> UserWorkout? {
        return userService.fetchLatestUserWorkout()
    }

    public func fetchWorkout(category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?, weights: Bool, dryGround: Bool) -> WorkoutManagedObject? {
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
        do {
            let optionalIds = try context.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            var excludedWorkouts = Set<String>()
            for w in currentUserWorkout.workouts {
                excludedWorkouts.insert(w.name)
            }
            if let last = lastUserWorkout {
                for w in last.workouts {
                    excludedWorkouts.insert(w.name)
                }
            }
            if var ids = optionalIds {
                if ids.count > 0 {
                    return randomWorkout(&ids, excludedWorkouts: excludedWorkouts)
                } else {
                    debugPrint("No ids!!!")
                }
            }
        } catch let error as NSError {
            debugPrint("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    public func fetchWorkoutProtocol(category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?, weights: Bool, dryGround: Bool) -> WorkoutProtocol? {
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
        do {
            let optionalIds = try context.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            var excludedWorkouts = Set<String>()
            for w in currentUserWorkout.workouts {
                excludedWorkouts.insert(w.name)
            }
            if let last = lastUserWorkout {
                for w in last.workouts {
                    excludedWorkouts.insert(w.name)
                }
            }
            if var ids = optionalIds {
                if ids.count > 0 {
                    return randomWorkout2(&ids, excludedWorkouts: excludedWorkouts)
                } else {
                    debugPrint("No ids!!!")
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    public func loadDataIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        var error: NSError? = nil
        let results = context.countForFetchRequest(fetchRequest, error: &error)
        if (results == 0) {
            let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
            importData(jsonURL!)
        }
    }

    public func importData(jsonURL: NSURL) {
        //let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL)!
        do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? NSDictionary
            if let json = jsonDict {
                debugPrint("Import seed data...")
                let workoutsJson = json.valueForKeyPath("workouts") as! NSDictionary
                let workouts = parseWorkouts(workoutsJson)
                addRepWorkouts(workoutsJson, workouts: workouts)
                addDurationWorkouts(workoutsJson, workouts: workouts)
                addPrebensWorkouts(workoutsJson, workouts: workouts)
                addIntervalWorkouts(workoutsJson, workouts: workouts)
                saveContext()
            }
        } catch let error as NSError {
            print("could not parse json data. \(error)")
        }
    }

    private struct WorkoutStruct {
        var name: String
        var desc: String
        var language: String
        var videoUrl: String
        var weights: Bool
        var dryGround: Bool
    }

    private func saveContext() {
        var error: NSError?
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
            debugPrint("Could not save \(error), \(error?.userInfo)")
        }
    }

    private func newWorkoutEntity(name: String, desc: String, categories: [WorkoutCategory]) -> WorkoutManagedObject {
        let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
        let workout = WorkoutManagedObject(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.name = name
        workout.workoutDescription = desc
        workout.categories = WorkoutCategory.asCsvString(categories)
        return workout
    }

    internal func newRepsWorkout() -> RepsWorkoutManagedObject {
        let repsWorkoutEntity = NSEntityDescription.entityForName(WorkoutService.repsEntityName, inManagedObjectContext: context)
        let repsWorkout = RepsWorkoutManagedObject(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.type = WorkoutType.Reps.rawValue
        return repsWorkout
    }

    internal func newDurationWorkout() -> DurationWorkoutManagedObject {
        let durationEntity = NSEntityDescription.entityForName(WorkoutService.durationEntityName, inManagedObjectContext: context)
        let durationWorkout = DurationWorkoutManagedObject(entity: durationEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.type = WorkoutType.Timed.rawValue
        return durationWorkout
    }

    internal func newIntervalWorkout() -> IntervalWorkoutManagedObject {
        let intervalEntity = NSEntityDescription.entityForName(WorkoutService.intervalEntityName, inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkoutManagedObject(entity: intervalEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.type = WorkoutType.Interval.rawValue
        return intervalWorkout
    }

    internal func newPrebensWorkout() -> PrebensWorkoutManagedObject {
        let prebensEntity = NSEntityDescription.entityForName(WorkoutService.prebensEntityName, inManagedObjectContext: context)
        let prebensWorkout = PrebensWorkoutManagedObject(entity: prebensEntity!, insertIntoManagedObjectContext: context)
        prebensWorkout.type = WorkoutType.Prebens.rawValue
        return prebensWorkout
    }

    private func executeFetchWorkout<T: AnyObject>(request: NSFetchRequest) -> [T]? {
        do {
            if let results = try context.executeFetchRequest(request) as? [T] {
                return results
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    public class func random (lower lower: Int , upper: Int) -> Int {
        let l:UInt32 = UInt32(lower)
        let r:UInt32 = UInt32(upper - lower + 1)
        return Int(l + r)
    }

    public func reps(reps: NSNumber) -> RepsBuilder {
        return RepsBuilder(workoutService: self).reps(reps)
    }

    public func reps() -> RepsBuilder {
        return RepsBuilder(workoutService: self)
    }

    public func duration(duration: NSNumber) -> DurationBuilder {
        return DurationBuilder(workoutService: self).duration(duration)
    }

    public func interval(work: DurationWorkoutProtocol, duration: Int) -> IntervalBuilder {
        return IntervalBuilder(workoutService: self).work(work, duration: duration)
    }

    public func prebens() -> PrebensBuilder {
        return PrebensBuilder(workoutService: self)
    }

    private func parseWorkouts(workoutsJson: NSDictionary) -> [String: WorkoutStruct] {
        var workouts = [String: WorkoutStruct]()
        for jsonDictionary in workoutsJson.valueForKeyPath("workout") as! NSArray {
            let workout = WorkoutStruct(name: jsonDictionary["name"] as! String!,
                desc: jsonDictionary["desc"] as! String!,
                language: jsonDictionary["language"] as! String!,
                videoUrl: jsonDictionary["videoUrl"] as! String!,
                weights: jsonDictionary["weights"] as! Bool!,
                dryGround: jsonDictionary["dryGround"] as! Bool!)
                workouts[workout.name] = workout
        }
        return workouts
    }

    private func addRepWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for json in workoutsJson.valueForKeyPath("repbased") as! NSArray {
            let workout = workouts[json["workout"] as! String!]!
            reps(json["reps"] as! NSNumber)
                .name(workout.name)
                .workoutName(json["name"] as! String)
                .description(workout.desc)
                .videoUrl(workout.videoUrl)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .approx(json["approx"] as! NSNumber)
                .postRestTime(json["rest"] as! NSNumber)
                .categories(json["categories"] as! String)
                .saveRepsWorkout()
        }

    }

    private func addDurationWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.valueForKeyPath("timebased") as! NSArray {
            let workout = workouts[jsonDictionary["workout"] as! String!]!
            duration(jsonDictionary["duration"] as! NSNumber!)
                .name(workout.name)
                .workoutName(jsonDictionary["name"] as! String!)
                .description(workout.desc)
                .videoUrl(workout.videoUrl)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .postRestTime(jsonDictionary["rest"] as! NSNumber)
                .categories(jsonDictionary["categories"] as! String)
                .saveDurationWorkout()
        }
    }

    private func addPrebensWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.valueForKeyPath("prebensbased") as! NSArray {
            let workout = workouts[jsonDictionary["workout"] as! String!]!
            let prebensWorkout = prebens()
                .name(workout.name)
                .workoutName(jsonDictionary["name"] as! String)
                .description(workout.desc)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .categories(jsonDictionary["categories"] as! String)
            for (_, w) in (jsonDictionary.valueForKeyPath("workouts") as! NSArray).enumerate() {
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
                    .saveRepsWorkout())
            }
            prebensWorkout.savePrebensWorkout()
        }
    }

    private func addIntervalWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.valueForKeyPath("intervalbased") as! NSArray {
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
                .saveDurationWorkout()
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
                .saveDurationWorkout()
            let _ = interval(work, duration: work.duration().integerValue)
                .rest(rest, duration: rest.duration().integerValue)
                .name(workout.name)
                .workoutName(jsonDictionary["name"] as! String)
                .intervals(jsonDictionary["intervals"] as! Int)
                .description(workout.desc)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .categories(jsonDictionary["categories"] as! String)
                .saveIntervalWorkout()
        }
    }

}

public class WorkoutBuilder: CustomStringConvertible {

    let workoutService: WorkoutService
    let workout: WorkoutManagedObject

    init(workout: WorkoutManagedObject, workoutService: WorkoutService) {
        self.workout = workout
        self.workout.language = "en"
        self.workoutService = workoutService
    }

    public func name(name: String) -> Self {
        workout.name = name
        // setting this to the same as name. This need fixing!.
        workout.workoutName = name
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

    public func categories(categories: [WorkoutCategory]) -> Self {
        workout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    public func categories(categories: String) -> Self {
        workout.categories = categories
        return self
    }

    public func saveWorkout() -> WorkoutProtocol {
        saveContext()
        return workoutService.workoutFrom(workout)
    }

    internal func saveContext() {
        workoutService.saveContext()
    }

    public var description: String {
        return "\(workout.description)"
    }

}

public class RepsBuilder: WorkoutBuilder {

    typealias ProtocolType = RepsWorkoutProtocol
    let repsWorkout: RepsWorkoutManagedObject

    init(workoutService: WorkoutService) {
        repsWorkout = workoutService.newRepsWorkout()
        super.init(workout: repsWorkout, workoutService: workoutService)
    }

    public func reps(reps: NSNumber) -> Self {
        repsWorkout.repititions = reps
        return self
    }

    public func approx(approx: NSNumber) -> Self {
        repsWorkout.approx = approx
        return self
    }

    public override var description: String {
        return "RepsWorkout[reps=\(repsWorkout.repititions), approx=\(repsWorkout.approx), \(super.description)]"
    }

    public func saveRepsWorkout() -> RepsWorkoutProtocol {
        saveContext()
        return workoutService.repsWorkoutFrom(repsWorkout)
    }

}

public class DurationBuilder: WorkoutBuilder {

    let durationWorkout: DurationWorkoutManagedObject

    init(workoutService: WorkoutService) {
        durationWorkout = workoutService.newDurationWorkout()
        super.init(workout: durationWorkout, workoutService: workoutService)
    }

    public func duration(duration: NSNumber) -> Self {
        durationWorkout.duration = duration
        return self
    }

    public override var description: String {
        return "DurationWorkout[duration=\(durationWorkout.duration), \(super.description)]"
    }

    public func saveDurationWorkout() -> DurationWorkoutProtocol {
        saveContext()
        return workoutService.durationWorkoutFrom(durationWorkout)
    }

}

public class IntervalBuilder: WorkoutBuilder {

    let intervalWorkout: IntervalWorkoutManagedObject
    var work: DurationWorkoutManagedObject!
    var rest: DurationWorkoutManagedObject!
    var workDuration: Int!
    var restWorkoutDuration: Int!

    init(workoutService: WorkoutService) {
        intervalWorkout = workoutService.newIntervalWorkout()
        super.init(workout: intervalWorkout, workoutService: workoutService)
    }

    public func work(work: DurationWorkoutManagedObject, duration: Int) -> Self {
        self.work = work
        workDuration = duration
        return self
    }

    public func work(work: DurationWorkoutProtocol, duration: Int) -> Self {
        return self.work(workoutService.toManagedDurationWorkout(work), duration: duration)
    }

    public func workoutName() -> String {
        return work.name
    }

    public func rest(rest: DurationWorkoutManagedObject, duration: Int) -> Self {
        self.rest = rest
        restWorkoutDuration = duration
        return self
    }

    public func rest(rest: DurationWorkoutProtocol, duration: Int) -> Self {
        return self.rest(workoutService.toManagedDurationWorkout(rest), duration: duration)
    }

    public func intervals(intervals: Int) -> Self {
        intervalWorkout.intervals = intervals
        return self
    }

    public func saveIntervalWorkout() -> IntervalWorkoutProtocol {
        saveContext()
        intervalWorkout.work = fromWorkout(work, duration: workDuration)
        intervalWorkout.rest = fromWorkout(rest, duration: restWorkoutDuration)
        return workoutService.intervalWorkoutFrom(intervalWorkout)
    }

    private func fromWorkout(workout: DurationWorkoutManagedObject, duration: Int) -> DurationWorkoutManagedObject {
        let newWorkout = workoutService.newDurationWorkout()
        newWorkout.duration = duration
        newWorkout.name = workout.name
        newWorkout.workoutName = workout.workoutName
        newWorkout.workoutDescription = workout.workoutDescription
        newWorkout.videoUrl = workout.videoUrl
        newWorkout.language = workout.language
        newWorkout.weights = workout.weights
        newWorkout.dryGround = workout.dryGround
        newWorkout.restTime = 0
        newWorkout.categories = "Interval"
        return newWorkout
    }

}

public class PrebensBuilder: WorkoutBuilder {

    let prebensWorkout: PrebensWorkoutManagedObject
    var prebensWorkouts: NSMutableOrderedSet

    init(workoutService: WorkoutService) {
        prebensWorkout = workoutService.newPrebensWorkout()
        prebensWorkouts = prebensWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        super.init(workout: prebensWorkout, workoutService: workoutService)
    }

    public func workouts(workouts: [RepsWorkoutProtocol]) -> Self {
        for w in workouts {
            workItem(w)
        }
        return self
    }

    public func workItemFrom(workoutName: String, reps: Int) -> Self {
        let workout = workoutService.fetchWorkoutProtocol(workoutName) as! RepsWorkoutManagedObject
        let newRepsWorkout = workoutService.newRepsWorkout()
        newRepsWorkout.repititions = reps
        newRepsWorkout.name = workout.name
        newRepsWorkout.workoutName = workout.name
        newRepsWorkout.workoutDescription = workout.workoutDescription
        newRepsWorkout.videoUrl = workout.videoUrl
        newRepsWorkout.language = workout.language
        newRepsWorkout.weights = workout.weights
        newRepsWorkout.dryGround = workout.dryGround
        newRepsWorkout.approx = workout.approx
        newRepsWorkout.restTime = workout.restTime
        newRepsWorkout.categories = "Prebens"
        workItem(newRepsWorkout)
        return self
    }

    public func workItem(repsWorkout: RepsWorkoutManagedObject) -> Self {
        prebensWorkouts.addObject(repsWorkout)
        prebensWorkout.workouts = prebensWorkouts.copy() as! NSOrderedSet
        return self
    }

    public func workItem(repsWorkout: RepsWorkoutProtocol) -> Self {
        return self.workItem(workoutService.toManagedRepsWorkout(repsWorkout))
    }

    public func savePrebensWorkout() -> PrebensWorkoutProtocol {
        saveContext()
        return workoutService.prebensWorkoutFrom(prebensWorkout)
    }

}

