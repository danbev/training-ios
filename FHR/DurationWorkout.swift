//
//  TimedWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 11/01/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import CoreData

public class DurationWorkout: NSManagedObject, WorkoutProtocol {

    @NSManaged public var duration: NSNumber
    @NSManaged public var parent: Workout

    public func name() -> String {
        return parent.name()
    }

    public func desc() -> String {
        return parent.desc()
    }

    public func image() -> NSData {
        return parent.image()
    }

    public func language() -> String {
        return parent.modelLanguage
    }

    public func categories() -> [Category] {
        return parent.categories()
    }

    public func type() -> Type {
        return parent.type()
    }

}
