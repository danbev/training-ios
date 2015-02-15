//
//  RepsWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class RepsWorkout: NSManagedObject, Printable, WorkoutProtocol {

    @NSManaged public var reps: NSNumber
    @NSManaged public var parent: Workout

    public func name() -> String {
        return parent.modelName
    }

    public func desc() -> String {
        return parent.modelDescription
    }

    public func image() -> NSData {
        return parent.modelImage
    }

    public func language() -> String {
        return parent.modelLanguage
    }

    public func category() -> String {
        return parent.modelCategory
    }

    public override var description: String {
        return "RepsWorkout[reps=\(reps), workout=\(parent)]"
    }

}
