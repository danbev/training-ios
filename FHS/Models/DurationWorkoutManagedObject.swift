//
//  TimedWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

open class DurationWorkoutManagedObject: WorkoutManagedObject {

    @NSManaged open var duration: NSNumber

    open override var description: String {
        return "DurationWorkout[duration=\(duration), \(super.description)]"
    }

}
