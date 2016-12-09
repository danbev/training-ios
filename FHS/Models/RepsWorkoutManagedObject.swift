//
//  RepsWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

open class RepsWorkoutManagedObject: WorkoutManagedObject {

    @NSManaged open var repititions: NSNumber
    @NSManaged open var approx: NSNumber

    open override var description: String {
        return "RepsWorkout[reps=\(repititions), approx=\(approx), \(super.description)]"
    }

}
