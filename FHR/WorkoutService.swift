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
    private let repsEntityName = "RepsWorkout"
    private let durationEntityName = "DurationWorkout"
    private let intervalEntityName = "IntervalWorkout"
    private var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func addRepsWorkout(name: String, desc: String, reps: Int, types: Type...) -> RepsWorkout {
        let workout = newWorkoutEntity(name, desc: desc, types: types)
        let repsWorkoutEntity = NSEntityDescription.entityForName(repsEntityName, inManagedObjectContext: context)
        let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.reps = reps
        repsWorkout.parent = workout
        saveContext()
        return repsWorkout
    }

    public func addDurationWorkout(name: String, desc: String, duration: Int, types: Type...) -> DurationWorkout {
        let workout = newWorkoutEntity(name, desc: desc, types: types)
        let durationWorkoutEntity = NSEntityDescription.entityForName(durationEntityName, inManagedObjectContext: context)
        let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.duration = duration
        durationWorkout.parent = workout
        saveContext()
        return durationWorkout
    }

    public func addIntervalWorkout(name: String, desc: String, work: DurationWorkout, rest: DurationWorkout, types: Type...) -> IntervalWorkout {
        let workout = newWorkoutEntity(name, desc: desc, types: types)
        let intervalWorkoutEntity = NSEntityDescription.entityForName(intervalEntityName, inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkout(entity: intervalWorkoutEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.work = work
        intervalWorkout.rest = rest
        intervalWorkout.parent = workout
        saveContext()
        return intervalWorkout
    }

    public func fetchRepsWorkouts() -> Optional<[RepsWorkout]> {
        let rw: Optional<[RepsWorkout]> = fetchWorkouts(repsEntityName);
        return rw
    }

    public func fetchDurationWorkouts() -> Optional<[DurationWorkout]> {
        let dw: Optional<[DurationWorkout]> = fetchWorkouts(durationEntityName);
        return dw;
    }

    public func fetchIntervalWorkouts() -> Optional<[IntervalWorkout]> {
        let iw: Optional<[IntervalWorkout]> = fetchWorkouts(intervalEntityName);
        return iw;
    }

    public func fetchWorkout(name: String) -> Optional<Workout> {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format:"modelName == %@", name)
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func fetchWarmup() -> Optional<Workout> {
        let fetchRequest = NSFetchRequest(entityName: workoutEntityName)
        fetchRequest.predicate = NSPredicate(format: "modelTypes contains[cd] %@", "warmup")
        fetchRequest.fetchLimit = 1
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [Workout]?
        if let results = fetchedResults {
            return results[0]
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
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
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary?
        // store workouts by name so we can back reference them.
        var workouts = [String: Workout]()
        if let json = jsonDict {
            let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
            let workoutDict = jsonDict!.valueForKeyPath("workouts") as NSDictionary
            let workoutsArray = workoutDict.valueForKeyPath("workout") as NSArray
            for jsonDictionary in workoutsArray {
                let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
                workout.modelName = jsonDictionary["name"] as String!
                workout.modelDescription = jsonDictionary["desc"] as String!
                workout.modelLanguage = jsonDictionary["language"] as String!
                let imageName = jsonDictionary["image"] as NSString
                let image = UIImage(named:imageName)
                let photoData = UIImagePNGRepresentation(image)
                workout.modelImage = photoData
                workouts[workout.modelName] = workout
            }
            let repsWorkoutEntity = NSEntityDescription.entityForName(self.repsEntityName, inManagedObjectContext: context)
            let repsbasedArray = workoutDict.valueForKeyPath("repbased") as NSArray
            for jsonDictionary in repsbasedArray {
                let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
                repsWorkout.parent = workouts[jsonDictionary["workout"] as String!]!
                repsWorkout.reps = jsonDictionary["reps"] as NSNumber!
                repsWorkout.parent.modelTypes = jsonDictionary["types"] as String!
            }

            saveContext()
        } else {
            println("could not parse json data.")
        }
    }

    private func saveContext() {
        var error: NSError?
        if !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }

    private func newWorkoutEntity(name: String, desc: String, types: [Type]) -> Workout {
        let workoutEntity = NSEntityDescription.entityForName(self.workoutEntityName, inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.modelName = name
        workout.modelDescription = desc
        workout.modelTypes = Type.asCsvString(types)
        return workout;
    }

    private func fetchWorkouts<T:AnyObject>(entityName: String) -> Optional<[T]> {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [T]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
    }
}
