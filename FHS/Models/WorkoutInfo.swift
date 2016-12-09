//
//  CompletedWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 03/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

open class WorkoutInfo: NSManagedObject {

    @NSManaged open var date: Date
    @NSManaged open var duration: Double
    @NSManaged open var name: String

    open override var description: String {
        return "WorkoutInfo[duration=\(duration), name=\(name), date=\(date)]"
    }


}
public func ==(lhs: WorkoutInfo, rhs: WorkoutInfo) -> Bool {
    return lhs.name == rhs.name
}
