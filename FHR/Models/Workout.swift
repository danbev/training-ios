//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class Workout: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var workoutName: String
    @NSManaged public var workoutDescription: String
    @NSManaged public var language: String
    @NSManaged public var categories: String
    @NSManaged public var type: String
    @NSManaged public var videoUrl: String
    @NSManaged public var restTime: NSNumber
    @NSManaged public var userWorkout: UserWorkout
    @NSManaged public var workoutDuration: NSDate?
    @NSManaged public var weights: NSNumber?
    @NSManaged public var dryGround: NSNumber?

    public lazy var lazyCategories: [WorkoutCategory] = {
        // needs to be unowned otherwise a strong ref will hang around
        // after ARC has set a ref to self to nil.
        [unowned self] in
        let array = split(self.categories) { $0 == "," }
        return array.map { WorkoutCategory(rawValue: $0)! }
        }()

}
