//
//  UserWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 24/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

open class UserWorkout: NSManagedObject {

    @NSManaged open var id: String
    @NSManaged open var date: Date
    @NSManaged open var duration: Double
    @NSManaged open var done: Bool
    @NSManaged open var category: String
    @NSManaged open var workouts: NSOrderedSet


}
