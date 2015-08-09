//
//  IntervalWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData


public class IntervalWorkoutManagedObject: WorkoutManagedObject {

    @NSManaged public var work: DurationWorkoutManagedObject
    @NSManaged public var rest: DurationWorkoutManagedObject
    @NSManaged public var intervals: NSNumber

    public override var description: String {
        return "IntervalWorkoutManagedObject[\(super.description), intervals=\(intervals), work=\(work.description)), rest=\(rest.description)]"
    }

}
