//
//  RuntimeWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 18/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class RuntimeWorkout {

    public var currentUserWorkout: UserWorkout!
    public var lastUserWorkout: UserWorkout!

    public convenience init(lastUserWorkout: UserWorkout?) {
        self.init(currentUserWorkout: nil, lastUserWorkout: lastUserWorkout)
    }

    public init(currentUserWorkout: UserWorkout?, lastUserWorkout: UserWorkout?) {
        self.lastUserWorkout = lastUserWorkout
        if lastUserWorkout?.done == false {
            self.currentUserWorkout = lastUserWorkout
        } else {
            self.currentUserWorkout = currentUserWorkout
        }
    }

    public func category(ignoredCategories: Set<WorkoutCategory>) -> String {
        if currentUserWorkout != nil {
            if currentUserWorkout?.done == false {
                return currentUserWorkout!.category
            } else {
                WorkoutCategory(rawValue: currentUserWorkout!.category)!.next(ignoredCategories).rawValue
            }
        }

        if lastUserWorkout != nil {
            return WorkoutCategory(rawValue: lastUserWorkout!.category)!.next(ignoredCategories).rawValue
        }

        return WorkoutCategory.Warmup.next(ignoredCategories).rawValue
    }
}
