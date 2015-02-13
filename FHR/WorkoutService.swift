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

    var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func addRepsWorkout(name: String, desc: String, reps: Int) -> RepsWorkout {
        let workoutEntity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.name = name
        workout.desc = desc
        workout.category = "all"

        let repsWorkoutEntity = NSEntityDescription.entityForName("RepsWorkout", inManagedObjectContext: context)
        let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: context)
        repsWorkout.reps = reps
        repsWorkout.parent = workout

        var error: NSError?
        if !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return repsWorkout
    }

    public func addDurationWorkout(name: String, desc: String, duration: Int) -> DurationWorkout {
        let workoutEntity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.name = name
        workout.desc = desc
        workout.category = "all"

        let durationWorkoutEntity = NSEntityDescription.entityForName("DurationWorkout", inManagedObjectContext: context)
        let durationWorkout = DurationWorkout(entity: durationWorkoutEntity!, insertIntoManagedObjectContext: context)
        durationWorkout.duration = duration
        durationWorkout.parent = workout

        var error: NSError?
        if !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return durationWorkout
    }

    public func fetchRepsWorkouts() -> Optional<[RepsWorkout]> {
        let fetchRequest = NSFetchRequest(entityName: "RepsWorkout")
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [RepsWorkout]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func fetchDurationWorkouts() -> Optional<[DurationWorkout]> {
        let fetchRequest = NSFetchRequest(entityName: "DurationWorkout")
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [DurationWorkout]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func addIntervalWorkout(name: String, desc: String, work: DurationWorkout, rest: DurationWorkout) -> IntervalWorkout {
        let workoutEntity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
        workout.name = name
        workout.desc = desc
        workout.category = "all"

        let intervalWorkoutEntity = NSEntityDescription.entityForName("IntervalWorkout", inManagedObjectContext: context)
        let intervalWorkout = IntervalWorkout(entity: intervalWorkoutEntity!, insertIntoManagedObjectContext: context)
        intervalWorkout.work = work
        intervalWorkout.rest = rest
        intervalWorkout.parent = workout

        var error: NSError?
        if !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return intervalWorkout
    }

    public func fetchIntervalWorkouts() -> Optional<[IntervalWorkout]> {
        let fetchRequest = NSFetchRequest(entityName: "IntervalWorkout")
        var error: NSError?
        let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as [IntervalWorkout]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

    public func fetchWorkout(name: String) -> Optional<Workout> {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
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

    public func loadDataIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
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
        if let json = jsonDict {
            let workoutEntity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)

            let jsonArray = jsonDict!.valueForKeyPath("workouts") as NSArray
            for jsonDictionary in jsonArray {
                let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: context)
                workout.name = jsonDictionary["name"] as String!
                workout.desc = jsonDictionary["desc"] as String!
                workout.category = jsonDictionary["category"] as String!
                let imageName = jsonDictionary["image"] as NSString
                let image = UIImage(named:imageName)
                let photoData = UIImagePNGRepresentation(image)
                workout.image = photoData
            }
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("saved context")
            }
        } else {
            println("could not parse json data.")
        }
    }
}
