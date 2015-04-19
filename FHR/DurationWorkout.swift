//
//  TimedWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class DurationWorkout: Workout, WorkoutProtocol {

    @NSManaged public var duration: NSNumber
    @NSManaged public var parent: Workout

}
