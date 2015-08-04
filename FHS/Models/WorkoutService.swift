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
    private var context: NSManagedObjectContext
    private let userService: UserService

    public init(context: NSManagedObjectContext, userService: UserService) {
        self.context = context
        self.userService = userService
    }

    public func getUserService() -> UserService {
        return userService
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
            if let warmup = fetchWarmup(lastWorkout) {
                return userService.newUserWorkout(id)
                    .category(WorkoutCategory(rawValue: lastWorkout.category)!.next(settings.ignoredCategories))
                    .addWorkout(warmup.name)
                    .save()
            }
        } else {
            if let warmup = fetchWarmup() {
                return userService.newUserWorkout(id).category(WorkoutCategory.Warmup.next(settings.ignoredCategories))
                    .addWorkout(warmup.name)
                    .save()
            }
        }
        return nil
    }

    private func getDate() -> (year: Int, month: Int, day: Int) {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components(.CalendarUnitWeekday, fromDate: NSDate())
        return (components.year, components.month, components.day)
    }

    public func fetchRepsWorkouts() -> [RepsWorkout]? {
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
        if let results = context.executeFetchRequest(fetchRequest, error: &error) {
            var workoutNames = Set<String>()
            for var i = 0; i < results.count; i++ {
                if let dic = (results[i] as? [String : String]) {
                    if let name = dic["name"] {
                        workoutNames.insert(name)
                    }
                }
            }
            var a = Array(workoutNames)
            sort(&a)
            return a
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchDurationWorkouts() -> [DurationWorkout]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.durationEntityName))
    }

    public func fetchIntervalWorkouts() -> [IntervalWorkout]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.intervalEntityName))
    }

    public func fetchPrebensWorkouts() -> [PrebensWorkout]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.prebensEntityName))
    }

    public func fetchWorkout(name: String) -> Workout? {
        println("fetching \(name)")
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    public func fetchWarmup() -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    public func fetchWarmup(userWorkout: UserWorkout) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        var error: NSError?
        let optionalIds = context.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObjectID]?
        var exludedWorkouts = Set<String>()
        for w in userWorkout.workouts {
            let workoutInfo = w as! WorkoutInfo
            exludedWorkouts.insert(workoutInfo.name)
        }
        if var ids = optionalIds {
            return randomWorkout(&ids, excludedWorkouts: exludedWorkouts)
        } else {
            debugPrintln("Could not fetch \(error), \(error!.userInfo)")
        }
        return nil
    }

    public func fetchLatestPerformed(name: String) -> WorkoutInfo? {
        return userService.fetchPerformedWorkoutInfo(name)
    }

    private func randomWorkout(inout objectIds: [NSManagedObjectID], excludedWorkouts: Set<String>) -> Workout? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        var error: NSError?
        if let workout = context.existingObjectWithID(objectId, error: &error) as! Workout? {
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
        } else {
            debugPrintln("Could not get a random workout \(error), \(error!.userInfo)")
            return nil
        }
    }

    public func fetchLatestUserWorkout() -> UserWorkout? {
        return userService.fetchLatestUserWorkout()
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
            let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
            importData(jsonURL!)
        }
    }

    public func importData(jsonURL: NSURL) {
        var error: NSError? = nil
        //let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
        let jsonData = NSData(contentsOfURL: jsonURL)!
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as! NSDictionary?
        if let json = jsonDict {
            debugPrintln("Import seed data...")
            let workoutsJson = jsonDict!.valueForKeyPath("workouts") as! NSDictionary
            var workouts = parseWorkouts(workoutsJson)
            addRepWorkouts(workoutsJson, workouts: workouts)
            addDurationWorkouts(workoutsJson, workouts: workouts)
            addPrebensWorkouts(workoutsJson, workouts: workouts)
            addIntervalWorkouts(workoutsJson, workouts: workouts)
            saveContext()
        } else {
            debugPrintln("could not parse json data. \(error)")
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
        return workout
    }

    internal func newRepsWorkout() -> RepsWorkout {
        let repsWorkoutEntity = NSEntityDescription.entityForName(WorkoutService.repsEntityName, inManagedObjectContext: context)
        let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.type = WorkoutType.Reps.rawValue
        return repsWorkout
    }

    internal func newDurationWorkout() -> DurationWorkout {
        let durationEntity = NSEntityDescription.entityForName(WorkoutService.durationEntityName, inManagedObjectContext: context)
        let durationWorkout = DurationWorkout(entity: durationEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.type = WorkoutType.Timed.rawValue
        return durationWorkout
    }

    internal func newIntervalWorkout() -> IntervalWorkout {
        let intervalEntity = NSEntityDescription.entityForName(WorkoutService.intervalEntityName, inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkout(entity: intervalEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.type = WorkoutType.Interval.rawValue
        return intervalWorkout
    }

    internal func newPrebensWorkout() -> PrebensWorkout {
        let prebensEntity = NSEntityDescription.entityForName(WorkoutService.prebensEntityName, inManagedObjectContext: context)
        let prebensWorkout = PrebensWorkout(entity: prebensEntity!, insertIntoManagedObjectContext: context)
        prebensWorkout.type = WorkoutType.Prebens.rawValue
        return prebensWorkout
    }

    private func executeFetchWorkout<T: AnyObject>(request: NSFetchRequest) -> [T]? {
        var error: NSError?
        if let results = context.executeFetchRequest(request, error: &error) as! [T]? {
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
        return RepsBuilder(workoutService: self).reps(reps)
    }

    public func reps() -> RepsBuilder {
        return RepsBuilder(workoutService: self)
    }

    public func duration(duration: NSNumber) -> DurationBuilder {
        return DurationBuilder(workoutService: self).duration(duration)
    }

    public func interval(work: DurationWorkout, duration: Int) -> IntervalBuilder {
        return IntervalBuilder(workoutService: self).work(work, duration: duration)
    }

    public func prebens() -> PrebensBuilder {
        return PrebensBuilder(workoutService: self)
    }

    private func parseWorkouts(workoutsJson: NSDictionary) -> [String: WorkoutContainer] {
        var workouts = [String: WorkoutContainer]()
        for jsonDictionary in workoutsJson.valueForKeyPath("workout") as! NSArray {
            let workout = WorkoutContainer(name: jsonDictionary["name"] as! String!,
                desc: jsonDictionary["desc"] as! String!,
                language: jsonDictionary["language"] as! String!,
                videoUrl: jsonDictionary["videoUrl"] as! String!,
                weights: jsonDictionary["weights"] as! Bool!,
                dryGround: jsonDictionary["dryGround"] as! Bool!)
                workouts[workout.name] = workout
        }
        return workouts
    }

    private func addRepWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutContainer]) {
        for json in workoutsJson.valueForKeyPath("repbased") as! NSArray {
            let workout = workouts[json["workout"] as! String!]!
            let repsWorkout = reps(json["reps"] as! NSNumber)
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
                .save()
        }

    }

    private func addDurationWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutContainer]) {
        for jsonDictionary in workoutsJson.valueForKeyPath("timebased") as! NSArray {
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
                .save()
        }
    }

    private func addPrebensWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutContainer]) {
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
            for (i, w) in enumerate(jsonDictionary.valueForKeyPath("workouts") as! NSArray) {
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
                    .save())
            }
        }
    }

    private func addIntervalWorkouts(workoutsJson: NSDictionary, workouts: [String: WorkoutContainer]) {
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
                .save()
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
                .save()
            let intervalWorkout = interval(work, duration: work.duration.integerValue)
                .rest(rest, duration: rest.duration.integerValue)
                .name(workout.name)
                .workoutName(jsonDictionary["name"] as! String)
                .intervals(jsonDictionary["intervals"] as! Int)
                .description(workout.desc)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .categories(jsonDictionary["categories"] as! String)
                .save()
        }
    }

}

public class WorkoutBuilder: Printable {

    let workoutService: WorkoutService
    let workout: Workout

    init(workout: Workout, workoutService: WorkoutService) {
        self.workout = workout
        self.workoutService = workoutService
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

    public func categories(categories: [WorkoutCategory]) -> Self {
        workout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    public func categories(categories: String) -> Self {
        workout.categories = categories
        return self
    }

    public func save() -> Workout {
        saveContext()
        return workout
    }

    internal func saveContext() {
        workoutService.saveContext()
    }

    public var description: String {
        return "\(workout.description)"
    }

}

public class RepsBuilder: WorkoutBuilder {

    let repsWorkout: RepsWorkout

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

    override public func save() -> RepsWorkout {
        saveContext()
        return repsWorkout
    }

}

public class DurationBuilder: WorkoutBuilder {

    let durationWorkout: DurationWorkout

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

    override public func save() -> DurationWorkout {
        saveContext()
        return durationWorkout
    }

}

public class IntervalBuilder: WorkoutBuilder {

    let intervalWorkout: IntervalWorkout
    var work: DurationWorkout!
    var rest: DurationWorkout!
    var workDuration: Int!
    var restWorkoutDuration: Int!

    init(workoutService: WorkoutService) {
        intervalWorkout = workoutService.newIntervalWorkout()
        super.init(workout: intervalWorkout, workoutService: workoutService)
    }

    public func work(work: DurationWorkout, duration: Int) -> Self {
        self.work = work
        workDuration = duration
        return self
    }

    public func workoutName() -> String {
        return work.name
    }

    public func rest(rest: DurationWorkout, duration: Int) -> Self {
        self.rest = rest
        restWorkoutDuration = duration
        return self
    }

    public func intervals(intervals: Int) -> Self {
        intervalWorkout.intervals = intervals
        return self
    }

    override public func save() -> IntervalWorkout {
        intervalWorkout.work = fromWorkout(work, duration: workDuration)
        intervalWorkout.rest = fromWorkout(rest, duration: restWorkoutDuration)
        saveContext()
        return intervalWorkout
    }

    private func fromWorkout(workout: DurationWorkout, duration: Int) -> DurationWorkout {
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

    let prebensWorkout: PrebensWorkout
    var prebensWorkouts: NSMutableOrderedSet

    init(workoutService: WorkoutService) {
        prebensWorkout = workoutService.newPrebensWorkout()
        prebensWorkouts = prebensWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        super.init(workout: prebensWorkout, workoutService: workoutService)
    }

    public func workouts(workouts: [RepsWorkout]) -> Self {
        for w in workouts {
            workItem(w)
        }
        return self
    }

    public func workItemFrom(workoutName: String, reps: Int) -> Self {
        let workout = workoutService.fetchWorkout(workoutName) as! RepsWorkout
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

    public func workItem(repsWorkout: RepsWorkout) -> Self {
        prebensWorkouts.addObject(repsWorkout)
        prebensWorkout.workouts = prebensWorkouts.copy() as! NSOrderedSet
        return self
    }

    override public func save() -> PrebensWorkout {
        saveContext()
        return prebensWorkout
    }

}

