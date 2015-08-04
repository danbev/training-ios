//
//  CompletedWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 03/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class WorkoutInfo: NSManagedObject, Printable, Equatable {

    @NSManaged public var date: NSDate
    @NSManaged public var duration: Double
    @NSManaged public var name: String

    public override var description: String {
        return "WorkoutInfo[duration=\(duration), name=\(name), date=\(date)]"
    }


}
public func ==(lhs: WorkoutInfo, rhs: WorkoutInfo) -> Bool {
    return lhs.name == rhs.name
}