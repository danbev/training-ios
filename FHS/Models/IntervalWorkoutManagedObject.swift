//
//  IntervalWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData


open class IntervalWorkoutManagedObject: WorkoutManagedObject {

    @NSManaged open var work: DurationWorkoutManagedObject
    @NSManaged open var rest: DurationWorkoutManagedObject
    @NSManaged open var intervals: NSNumber

    open override var description: String {
        return "IntervalWorkoutManagedObject[\(super.description), intervals=\(intervals), work=\(work.description)), rest=\(rest.description)]"
    }

}
