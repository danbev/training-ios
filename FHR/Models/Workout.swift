//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class Workout: NSManagedObject, WorkoutProtocol {

    @NSManaged public var modelName: String
    @NSManaged public var modelWorkoutName: String
    @NSManaged public var modelDescription: String
    @NSManaged public var modelLanguage: String
    @NSManaged public var modelCategories: String
    @NSManaged public var modelType: String
    @NSManaged public var videoUrl: String
    @NSManaged public var modelRestTime: NSNumber
    @NSManaged public var userWorkout: UserWorkout
    @NSManaged public var modelDuration: NSDate?
    @NSManaged public var weights: NSNumber?
    @NSManaged public var dryGround: NSNumber?

    public func name() -> String {
        return modelName
    }

    public func workoutName() -> String {
        return modelWorkoutName
    }

    public func desc() -> String {
        return modelDescription
    }

    public lazy var lazyCategories: [WorkoutCategory] = {
        // needs to be unowned otherwise a strong ref will hang around
        // after ARC has set a ref to self to nil.
        [unowned self] in
        let array = split(self.modelCategories) { $0 == "," }
        return array.map { WorkoutCategory(rawValue: $0)! }
        }()

    public func categories() -> [WorkoutCategory] {
        return lazyCategories;
    }

    public func language() -> String {
        return modelLanguage
    }

    public func restTime() -> NSNumber {
        return modelRestTime
    }

    public func type() -> Type {
        return Type(rawValue: modelType)!
    }

}
