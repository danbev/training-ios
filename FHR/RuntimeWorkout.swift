//
//  RuntimeWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 18/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class RuntimeWorkout {

    public var currentWorkout: UserWorkout!
    public var lastWorkout: UserWorkout!

    public convenience init(lastWorkout: UserWorkout?) {
        self.init(currentWorkout: nil, lastWorkout: lastWorkout)
    }

    public init(currentWorkout: UserWorkout?, lastWorkout: UserWorkout?) {
        self.currentWorkout = currentWorkout
        self.lastWorkout = lastWorkout
    }

    public func category(ignoredCategories: Set<WorkoutCategory>) -> String {
        if currentWorkout != nil {
            if currentWorkout?.done == false {
                return currentWorkout!.category
            } else {
                WorkoutCategory(rawValue: currentWorkout!.category)!.next(ignoredCategories).rawValue
            }
        }

        if lastWorkout != nil {
            return WorkoutCategory(rawValue: lastWorkout!.category)!.next(ignoredCategories).rawValue
        }

        return WorkoutCategory.Warmup.next(ignoredCategories).rawValue
    }
}
