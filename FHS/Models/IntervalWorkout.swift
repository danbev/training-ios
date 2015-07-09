//
//  IntervalWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData


public class IntervalWorkout: Workout {

    @NSManaged public var work: DurationWorkout
    @NSManaged public var rest: DurationWorkout
    @NSManaged public var intervals: NSNumber

    public override var description: String {
        return "IntervalWorkout[\(super.description), intervals=\(intervals), work=\(work.description)), rest=\(rest.description)]"
    }

}