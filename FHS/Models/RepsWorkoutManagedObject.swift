//
//  RepsWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class RepsWorkoutManagedObject: WorkoutManagedObject {

    @NSManaged public var repititions: NSNumber
    @NSManaged public var approx: NSNumber

    public override var description: String {
        return "RepsWorkout[reps=\(repititions), approx=\(approx), \(super.description)]"
    }

}
