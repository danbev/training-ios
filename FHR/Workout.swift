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
    @NSManaged public var modelDescription: String
    @NSManaged public var modelLanguage: String
    @NSManaged public var modelCategory: String
    @NSManaged public var modelImage: NSData
    @NSManaged public var reps: RepsWorkout
    @NSManaged public var timed: DurationWorkout

    public func name() -> String {
        return modelName
    }

    public func desc() -> String {
        return modelDescription
    }

    public func category() -> String {
        return modelCategory
    }

    public func language() -> String {
        return modelLanguage
    }

    public func image() -> NSData {
        return modelImage
    }

}
