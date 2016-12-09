//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

/**
Represents a workout in the CoreData model
*/
open class WorkoutManagedObject: NSManagedObject {

    @NSManaged open var name: String
    @NSManaged open var workoutName: String
    @NSManaged open var workoutDescription: String
    @NSManaged open var language: String
    @NSManaged open var categories: String
    @NSManaged open var type: String
    @NSManaged open var videoUrl: String?
    @NSManaged open var restTime: NSNumber
    @NSManaged open var userWorkout: UserWorkout
    @NSManaged open var workoutDuration: Date?
    @NSManaged open var weights: NSNumber?
    @NSManaged open var dryGround: NSNumber?

    open lazy var lazyCategories: [WorkoutCategory] = {
        // needs to be unowned otherwise a strong ref will hang around
        // after ARC has set a ref to self to nil.
        [unowned self] in
        let array = self.categories.characters.split { $0 == "," }.map { String($0) }
        return array.map { WorkoutCategory(rawValue: $0)! }
    }()

    open override var description: String {
        return "name=\(name), workoutName=\(workoutName), description=\(workoutDescription), videoUrl=\(videoUrl), language=\(language), weights=\(weights), dryGround=\(dryGround), restTime=\(restTime), categories=\(categories)"
    }

}
