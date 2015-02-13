//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class Workout: NSManagedObject {

    @NSManaged public var desc: String
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var image: NSData
    @NSManaged public var reps: RepsWorkout
    @NSManaged public var timed: DurationWorkout

}
