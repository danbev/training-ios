//
//  Workout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

class Workout: NSManagedObject {

    @NSManaged var desc: String
    @NSManaged var name: String
    @NSManaged var reps: NSManagedObject
    @NSManaged var timed: NSManagedObject

}
