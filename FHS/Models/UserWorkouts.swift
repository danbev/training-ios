//
//  UserWorkouts.swift
//  FHR
//
//  Created by Daniel Bevenius on 30/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class UserWorkouts: NSManagedObject {

    @NSManaged public var workoutName: String
    @NSManaged public var duration: Double

}
