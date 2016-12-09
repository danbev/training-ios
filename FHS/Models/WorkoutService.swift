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

open class WorkoutService {

    fileprivate static let repsEntityName = "RepsWorkout"
    fileprivate static let durationEntityName = "DurationWorkout"
    fileprivate static let intervalEntityName = "IntervalWorkout"
    fileprivate static let prebensEntityName = "PrebensWorkout"
    fileprivate let workoutEntityName = "Workout"
    fileprivate var context: NSManagedObjectContext
    fileprivate let userService: UserService
    fileprivate let coreDataStack: CoreDataStack

    public init(coreDataStack: CoreDataStack, userService: UserService) {
        self.coreDataStack = coreDataStack
        context = coreDataStack.context
        self.userService = userService
    }

    open func getUserService() -> UserService {
        return userService
    }

    open func stores() -> [String] {
        return coreDataStack.storeNames
    }

    open func newUserWorkout(_ lastUserWorkout: UserWorkout?, settings: Settings) -> UserWorkout? {
        let id = UUID().uuidString
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

    open func removeUserWorkout(_ workout: WorkoutProtocol) {
        if let workout = fetchWorkout(workout.name()) {
            context.delete(workout);
        }
    }

    fileprivate func getDate() -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (calendar as NSCalendar).components(.weekday, from: Date())
        return (components.year!, components.month!, components.day!)
    }

    open func fetchRepsWorkouts() -> [RepsWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.repsEntityName))
    }

    open func fetchRepsWorkoutsDestinct() -> [String]? {
        return fetchWorkoutsDestinct(WorkoutService.repsEntityName)
    }

    open func fetchDurationWorkoutsDestinct() -> [String]? {
        return fetchWorkoutsDestinct(WorkoutService.durationEntityName)
    }

    open func fetchWorkoutsDestinct(_ entityName: String) -> [String]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.propertiesToFetch = ["name"]
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: NSError?
        do {
            let results = try context.fetch(fetchRequest)
            var workoutNames = Set<String>()
            for i in 0 ..< results.count {
                if let dic = (results[i] as? [String : String]) {
                    if let name = dic["name"] {
                        workoutNames.insert(name)
                    }
                }
            }
            var a = Array(workoutNames)
            a.sort()
            return a
        } catch let error1 as NSError {
            error = error1
            debugPrint("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }

    open func fetchDurationWorkouts() -> [DurationWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.durationEntityName))
    }

    open func fetchIntervalWorkouts() -> [IntervalWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.intervalEntityName))
    }

    open func fetchPrebensWorkouts() -> [PrebensWorkoutManagedObject]? {
        return executeFetchWorkout(NSFetchRequest(entityName: WorkoutService.prebensEntityName))
    }

    open func fetchWorkoutProtocol(_ name: String) -> WorkoutProtocol? {
        if let managedWorkout = fetchWorkout(name) {
            return managedWorkoutToProtocol(managedWorkout)
        }
        return nil
    }

    open func managedWorkoutToProtocol(_ managedWorkout: WorkoutManagedObject) -> WorkoutProtocol {
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

    fileprivate func repsSetFrom(_ repsWorkouts: NSOrderedSet) -> [RepsWorkout] {
        var set = [RepsWorkout]()
        for w in repsWorkouts {
            set.append(repsWorkoutFrom(w as! RepsWorkoutManagedObject))
        }
        return set
    }

    fileprivate func intervalWorkoutFrom(_ managedIntervalWorkout: IntervalWorkoutManagedObject) -> IntervalWorkoutProtocol {
        return IntervalWorkout(workout: workoutFrom(managedIntervalWorkout),
            work: durationWorkoutFrom(managedIntervalWorkout.work),
            rest: durationWorkoutFrom(managedIntervalWorkout.rest),
            intervals: managedIntervalWorkout.intervals)
    }

    fileprivate func prebensWorkoutFrom(_ managedPrebensWorkout: PrebensWorkoutManagedObject) -> PrebensWorkoutProtocol {
        let workouts = managedPrebensWorkout.workouts
        return PrebensWorkout(workout: workoutFrom(managedPrebensWorkout), workouts: repsSetFrom(workouts))
    }

    fileprivate func repsWorkoutFrom(_ managedRepsWorkout: RepsWorkoutManagedObject) -> RepsWorkout {
        return RepsWorkout(workout: workoutFrom(managedRepsWorkout), reps: managedRepsWorkout.repititions, approx: managedRepsWorkout.approx)
    }

    fileprivate func durationWorkoutFrom(_ managedDurationWorkout: DurationWorkoutManagedObject) -> DurationWorkout {
        return DurationWorkout(workout: workoutFrom(managedDurationWorkout), duration: managedDurationWorkout.duration)
    }

    fileprivate func setWorkoutProperties(_ instance: WorkoutManagedObject, workoutProtocol: WorkoutProtocol) {
        instance.name = workoutProtocol.name()
        instance.workoutName = workoutProtocol.workoutName()
        instance.workoutDescription = workoutProtocol.workoutDescription()
        instance.language = workoutProtocol.language()
        instance.categories = workoutProtocol.categories()
        instance.videoUrl = workoutProtocol.videoUrl()
        instance.restTime = workoutProtocol.restTime()
        instance.weights = workoutProtocol.weights() as NSNumber?
        instance.dryGround = workoutProtocol.dryGround() as NSNumber?
    }

    fileprivate func toManagedDurationWorkout(_ durationProtocol: DurationWorkoutProtocol) -> DurationWorkoutManagedObject {
        let durationWorkout = newDurationWorkout()
        setWorkoutProperties(durationWorkout, workoutProtocol: durationProtocol)
        durationWorkout.duration = durationProtocol.duration()
        return durationWorkout
    }

    fileprivate func toManagedRepsWorkout(_ repsProtocol: RepsWorkoutProtocol) -> RepsWorkoutManagedObject {
        let repsWorkout = newRepsWorkout()
        setWorkoutProperties(repsWorkout, workoutProtocol: repsProtocol)
        repsWorkout.repititions = repsProtocol.repititions()
        repsWorkout.approx = repsProtocol.approx()
        return repsWorkout
    }

    open func workoutFrom(_ managedWorkout: WorkoutManagedObject) -> WorkoutProtocol {
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

    fileprivate func fetchWorkout(_ name: String) -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    fileprivate func fetchWarmup() -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        fetchRequest.fetchLimit = 1
        return executeFetchWorkout(fetchRequest)?.first
    }

    open func fetchWarmupProtocol() -> WorkoutProtocol? {
        if let managedWorkout = fetchWarmup() {
            return managedWorkoutToProtocol(managedWorkout)
        }
        return nil
    }

    open func fetchWarmupProtocol(_ userWorkout: UserWorkout) -> WorkoutProtocol? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        do {
            let optionalIds = try self.context.fetch(fetchRequest) as? [NSManagedObjectID]
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

    fileprivate func fetchWarmup(_ userWorkout: UserWorkout) -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@", "Warmup")
        do {
            let optionalIds = try context.fetch(fetchRequest) as? [NSManagedObjectID]
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

    open func fetchLatestPerformed(_ name: String) -> WorkoutInfo? {
        return userService.fetchPerformedWorkoutInfo(name)
    }

    fileprivate func randomWorkout2(_ objectIds: inout [NSManagedObjectID], excludedWorkouts: Set<String>) -> WorkoutProtocol? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        do {
            if let workout = try context.existingObject(with: objectId) as? WorkoutManagedObject {
                var doneLastWorkout = false
                for performedWorkout in excludedWorkouts {
                    if performedWorkout == workout.name {
                        doneLastWorkout = true
                        break
                    }
                }
                if doneLastWorkout {
                    objectIds.remove(at: index)
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

    fileprivate func randomWorkout(_ objectIds: inout [NSManagedObjectID], excludedWorkouts: Set<String>) -> WorkoutManagedObject? {
        let count = objectIds.count
        let index: Int = Int(arc4random_uniform(UInt32(count)))
        let objectId = objectIds[index]
        do {
            if let workout = try context.existingObject(with: objectId) as? WorkoutManagedObject {
                var doneLastWorkout = false
                for performedWorkout in excludedWorkouts {
                    if performedWorkout == workout.name {
                        doneLastWorkout = true
                        break
                    }
                }
                if doneLastWorkout {
                    objectIds.remove(at: index)
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

    open func fetchLatestUserWorkout() -> UserWorkout? {
        return userService.fetchLatestUserWorkout()
    }

    open func fetchWorkout(_ category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?, weights: Bool, dryGround: Bool) -> WorkoutManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND weights = %@", category, weights as CVarArg)
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
            let optionalIds = try context.fetch(fetchRequest) as? [NSManagedObjectID]
            var excludedWorkouts = Set<String>()
            for w in currentUserWorkout.workouts {
                excludedWorkouts.insert((w as AnyObject).name)
            }
            if let last = lastUserWorkout {
                for w in last.workouts {
                    excludedWorkouts.insert((w as AnyObject).name)
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

    open func fetchWorkoutProtocol(_ category: String, currentUserWorkout: UserWorkout, lastUserWorkout: UserWorkout?, weights: Bool, dryGround: Bool) -> WorkoutProtocol? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "categories contains %@ AND weights = %@", category, weights as CVarArg)
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
            let optionalIds = try context.fetch(fetchRequest) as? [NSManagedObjectID]
            var excludedWorkouts = Set<String>()
            for w in currentUserWorkout.workouts {
                excludedWorkouts.insert((w as AnyObject).name)
            }
            if let last = lastUserWorkout {
                for w in last.workouts {
                    excludedWorkouts.insert((w as AnyObject).name)
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

    open func loadDataIfNeeded() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        //var error: NSError? = nil
        do {
            let results = try context.count(for: fetchRequest)
            if (results == 0) {
                let jsonURL = Bundle.main.url(forResource: "workouts", withExtension: "json")
                importData(jsonURL!)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    open func importData(_ jsonURL: URL) {
        //let jsonURL = NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")
        let jsonData = try! Data(contentsOf: jsonURL)
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary
            if let json = jsonDict {
                debugPrint("Import seed data...")
                let workoutsJson = json.value(forKeyPath: "workouts") as! NSDictionary
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

    fileprivate struct WorkoutStruct {
        var name: String
        var desc: String
        var language: String
        var videoUrl: String
        var weights: Bool
        var dryGround: Bool
    }

    fileprivate func saveContext() {
        var error: NSError?
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
            debugPrint("Could not save \(error), \(error?.userInfo)")
        }
    }

    fileprivate func newWorkoutEntity(_ name: String, desc: String, categories: [WorkoutCategory]) -> WorkoutManagedObject {
        let workoutEntity = NSEntityDescription.entity(forEntityName: self.workoutEntityName, in: context)
        let workout = WorkoutManagedObject(entity: workoutEntity!, insertInto: context)
        workout.name = name
        workout.workoutDescription = desc
        workout.categories = WorkoutCategory.asCsvString(categories)
        return workout
    }

    internal func newRepsWorkout() -> RepsWorkoutManagedObject {
        let repsWorkoutEntity = NSEntityDescription.entity(forEntityName: WorkoutService.repsEntityName, in: context)
        let repsWorkout = RepsWorkoutManagedObject(entity: repsWorkoutEntity!, insertInto: context)
        repsWorkout.type = WorkoutType.Reps.rawValue
        return repsWorkout
    }

    internal func newDurationWorkout() -> DurationWorkoutManagedObject {
        let durationEntity = NSEntityDescription.entity(forEntityName: WorkoutService.durationEntityName, in: context)
        let durationWorkout = DurationWorkoutManagedObject(entity: durationEntity!, insertInto: context)
        durationWorkout.type = WorkoutType.Timed.rawValue
        return durationWorkout
    }

    internal func newIntervalWorkout() -> IntervalWorkoutManagedObject {
        let intervalEntity = NSEntityDescription.entity(forEntityName: WorkoutService.intervalEntityName, in: context)
        let intervalWorkout = IntervalWorkoutManagedObject(entity: intervalEntity!, insertInto: context)
        intervalWorkout.type = WorkoutType.Interval.rawValue
        return intervalWorkout
    }

    internal func newPrebensWorkout() -> PrebensWorkoutManagedObject {
        let prebensEntity = NSEntityDescription.entity(forEntityName: WorkoutService.prebensEntityName, in: context)
        let prebensWorkout = PrebensWorkoutManagedObject(entity: prebensEntity!, insertInto: context)
        prebensWorkout.type = WorkoutType.Prebens.rawValue
        return prebensWorkout
    }

    fileprivate func executeFetchWorkout<T: AnyObject>(_ request: NSFetchRequest<NSFetchRequestResult>) -> [T]? {
        do {
            if let results = try context.fetch(request) as? [T] {
                return results
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

    open class func random (lower: Int , upper: Int) -> Int {
        let l:UInt32 = UInt32(lower)
        let r:UInt32 = UInt32(upper - lower + 1)
        return Int(l + r)
    }

    open func reps(_ reps: Int) -> RepsBuilder {
        return RepsBuilder(workoutService: self).reps(reps as NSNumber)
    }

    open func reps() -> RepsBuilder {
        return RepsBuilder(workoutService: self)
    }

    open func duration(_ duration: NSNumber) -> DurationBuilder {
        return DurationBuilder(workoutService: self).duration(duration)
    }

    open func interval(_ work: DurationWorkoutProtocol, duration: Int) -> IntervalBuilder {
        return IntervalBuilder(workoutService: self).work(work, duration: duration)
    }

    open func prebens() -> PrebensBuilder {
        return PrebensBuilder(workoutService: self)
    }

    fileprivate func parseWorkouts(_ workoutsJson: NSDictionary) -> [String: WorkoutStruct] {
        var workouts = [String: WorkoutStruct]()
        for jsonDictionary in workoutsJson.value(forKeyPath: "workout") as! [[String:Any]] {
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

    fileprivate func addRepWorkouts(_ workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for json in workoutsJson.value(forKeyPath: "repbased") as! [[String:Any]] {
            let workout = workouts[json["workout"] as! String!]!
            let _ = reps(Int(json["reps"] as! NSNumber))
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

    fileprivate func addDurationWorkouts(_ workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.value(forKeyPath: "timebased") as! [[String:Any]] {
            let workout = workouts[jsonDictionary["workout"] as! String!]!
            let _ = duration(jsonDictionary["duration"] as! NSNumber!)
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

    fileprivate func addPrebensWorkouts(_ workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.value(forKeyPath: "prebensbased") as! [[String:Any]] {
            let workout = workouts[jsonDictionary["workout"] as! String!]!
            let prebensWorkout = prebens()
                .name(workout.name)
                .workoutName(jsonDictionary["name"] as! String)
                .description(workout.desc)
                .language(workout.language)
                .weights(workout.weights)
                .dryGround(workout.dryGround)
                .categories(jsonDictionary["categories"] as! String)
            for (_, w) in ((jsonDictionary as AnyObject).value(forKeyPath: "workouts") as! [[String:Any]]).enumerated() {
                let workout = workouts[w["workout"] as! String!]!
                let _ = prebensWorkout.workItem(reps(Int(w["reps"] as! NSNumber))
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
            let _ = prebensWorkout.savePrebensWorkout()
        }
    }

    fileprivate func addIntervalWorkouts(_ workoutsJson: NSDictionary, workouts: [String: WorkoutStruct]) {
        for jsonDictionary in workoutsJson.value(forKeyPath: "intervalbased") as! [[String:Any]] {
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
            let _ = interval(work, duration: work.duration().intValue)
                .rest(rest, duration: rest.duration().intValue)
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

open class WorkoutBuilder: CustomStringConvertible {

    let workoutService: WorkoutService
    let workout: WorkoutManagedObject

    init(workout: WorkoutManagedObject, workoutService: WorkoutService) {
        self.workout = workout
        self.workout.language = "en"
        self.workoutService = workoutService
    }

    open func name(_ name: String) -> Self {
        workout.name = name
        // setting this to the same as name. This need fixing!.
        workout.workoutName = name
        return self
    }

    open func workoutName(_ name: String) -> Self {
        workout.workoutName = name
        return self
    }

    open func description(_ description: String) -> Self {
        workout.workoutDescription = description
        return self
    }

    open func videoUrl(_ videoUrl: String?) -> Self {
        workout.videoUrl = videoUrl
        return self
    }

    open func language(_ language: String) -> Self {
        workout.language = language
        return self
    }

    open func weights(_ weights: Bool) -> Self {
        workout.weights = weights as NSNumber?
        return self
    }

    open func dryGround(_ dryGround: Bool) -> Self {
        workout.dryGround = dryGround as NSNumber?
        return self
    }

    open func postRestTime(_ restTime: NSNumber) -> Self {
        workout.restTime = restTime
        return self
    }

    open func categories(_ categories: WorkoutCategory...) -> Self {
        workout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    open func categories(_ categories: [WorkoutCategory]) -> Self {
        workout.categories = WorkoutCategory.asCsvString(categories)
        return self
    }

    open func categories(_ categories: String) -> Self {
        workout.categories = categories
        return self
    }

    open func saveWorkout() -> WorkoutProtocol {
        saveContext()
        return workoutService.workoutFrom(workout)
    }

    internal func saveContext() {
        workoutService.saveContext()
    }

    open var description: String {
        return "\(workout.description)"
    }

}

open class RepsBuilder: WorkoutBuilder {

    typealias ProtocolType = RepsWorkoutProtocol
    let repsWorkout: RepsWorkoutManagedObject

    init(workoutService: WorkoutService) {
        repsWorkout = workoutService.newRepsWorkout()
        super.init(workout: repsWorkout, workoutService: workoutService)
    }

    open func reps(_ reps: NSNumber) -> Self {
        repsWorkout.repititions = reps
        return self
    }

    open func approx(_ approx: NSNumber) -> Self {
        repsWorkout.approx = approx
        return self
    }

    open override var description: String {
        return "RepsWorkout[reps=\(repsWorkout.repititions), approx=\(repsWorkout.approx), \(super.description)]"
    }

    open func saveRepsWorkout() -> RepsWorkoutProtocol {
        saveContext()
        return workoutService.repsWorkoutFrom(repsWorkout)
    }

}

open class DurationBuilder: WorkoutBuilder {

    let durationWorkout: DurationWorkoutManagedObject

    init(workoutService: WorkoutService) {
        durationWorkout = workoutService.newDurationWorkout()
        super.init(workout: durationWorkout, workoutService: workoutService)
    }

    open func duration(_ duration: NSNumber) -> Self {
        durationWorkout.duration = duration
        return self
    }

    open override var description: String {
        return "DurationWorkout[duration=\(durationWorkout.duration), \(super.description)]"
    }

    open func saveDurationWorkout() -> DurationWorkoutProtocol {
        saveContext()
        return workoutService.durationWorkoutFrom(durationWorkout)
    }

}

open class IntervalBuilder: WorkoutBuilder {

    let intervalWorkout: IntervalWorkoutManagedObject
    var work: DurationWorkoutManagedObject!
    var rest: DurationWorkoutManagedObject!
    var workDuration: Int!
    var restWorkoutDuration: Int!

    init(workoutService: WorkoutService) {
        intervalWorkout = workoutService.newIntervalWorkout()
        super.init(workout: intervalWorkout, workoutService: workoutService)
    }

    open func work(_ work: DurationWorkoutManagedObject, duration: Int) -> Self {
        self.work = work
        workDuration = duration
        return self
    }

    open func work(_ work: DurationWorkoutProtocol, duration: Int) -> Self {
        return self.work(workoutService.toManagedDurationWorkout(work), duration: duration)
    }

    open func workoutName() -> String {
        return work.name
    }

    open func rest(_ rest: DurationWorkoutManagedObject, duration: Int) -> Self {
        self.rest = rest
        restWorkoutDuration = duration
        return self
    }

    open func rest(_ rest: DurationWorkoutProtocol, duration: Int) -> Self {
        return self.rest(workoutService.toManagedDurationWorkout(rest), duration: duration)
    }

    open func intervals(_ intervals: Int) -> Self {
        intervalWorkout.intervals = NSNumber(value: intervals)
        return self
    }

    open func saveIntervalWorkout() -> IntervalWorkoutProtocol {
        saveContext()
        intervalWorkout.work = fromWorkout(work, duration: workDuration)
        intervalWorkout.rest = fromWorkout(rest, duration: restWorkoutDuration)
        return workoutService.intervalWorkoutFrom(intervalWorkout)
    }

    fileprivate func fromWorkout(_ workout: DurationWorkoutManagedObject, duration: Int) -> DurationWorkoutManagedObject {
        let newWorkout = workoutService.newDurationWorkout()
        newWorkout.duration = NSNumber(value:duration)
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

open class PrebensBuilder: WorkoutBuilder {

    let prebensWorkout: PrebensWorkoutManagedObject
    var prebensWorkouts: NSMutableOrderedSet

    init(workoutService: WorkoutService) {
        prebensWorkout = workoutService.newPrebensWorkout()
        prebensWorkouts = prebensWorkout.workouts.mutableCopy() as! NSMutableOrderedSet
        super.init(workout: prebensWorkout, workoutService: workoutService)
    }

    open func workouts(_ workouts: [RepsWorkoutProtocol]) -> Self {
        for w in workouts {
            let _ = workItem(w)
        }
        return self
    }

    open func workItemFrom(_ workoutName: String, reps: Int) -> Self {
        let workout = workoutService.fetchWorkoutProtocol(workoutName) as! RepsWorkoutManagedObject
        let newRepsWorkout = workoutService.newRepsWorkout()
        newRepsWorkout.repititions = NSNumber(value: reps)
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
        let _ = workItem(newRepsWorkout)
        return self
    }

    open func workItem(_ repsWorkout: RepsWorkoutManagedObject) -> Self {
        prebensWorkouts.add(repsWorkout)
        prebensWorkout.workouts = prebensWorkouts.copy() as! NSOrderedSet
        return self
    }

    open func workItem(_ repsWorkout: RepsWorkoutProtocol) -> Self {
        return self.workItem(workoutService.toManagedRepsWorkout(repsWorkout))
    }

    open func savePrebensWorkout() -> PrebensWorkoutProtocol {
        saveContext()
        return workoutService.prebensWorkoutFrom(prebensWorkout)
    }

}

