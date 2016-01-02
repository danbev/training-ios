//
//  UserWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 24/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class UserWorkout: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var date: NSDate
    @NSManaged public var duration: Double
    @NSManaged public var done: Bool
    @NSManaged public var category: String
    @NSManaged public var workouts: NSOrderedSet


}
