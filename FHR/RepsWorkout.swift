//
//  RepsWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class RepsWorkout: NSManagedObject, Printable {

    @NSManaged public var reps: NSNumber
    @NSManaged public var parent: Workout

    public override var description: String {
        return "RepsWorkout[reps=\(reps), workout=\(parent)]"
    }

}
