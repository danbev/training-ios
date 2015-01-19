//
//  WorkoutTask.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

class WorkoutTask: NSManagedObject {

    @NSManaged var desc: String
    @NSManaged var name: String
    @NSManaged var timed: TimedWorkout
    @NSManaged var reps: RepsWorkout

}
