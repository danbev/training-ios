//
//  TimedWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

class TimedWorkout: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var parent: Workout

}
