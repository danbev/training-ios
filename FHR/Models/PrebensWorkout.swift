//
//  PrebensWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 26/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class PrebensWorkout: Workout, Printable, WorkoutProtocol {

    @NSManaged public var parent: Workout
    @NSManaged public var workouts: NSOrderedSet


}
