//
//  RuntimeWorkout.swift
//  FHR
//
//  Created by Daniel Bevenius on 18/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

open class RuntimeWorkout {

    open var currentUserWorkout: UserWorkout!
    open var lastUserWorkout: UserWorkout!
    fileprivate static let userDefaults: UserDefaults = UserDefaults.standard

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

    open func warmupCompleted(_ warmupSetting: Bool, numberOfWarmups: Int) -> Bool {
        if !warmupSetting {
            return true
        }
        return currentUserWorkout.workouts.count >= numberOfWarmups
    }

    open func category() -> String {
        let ignoredCategories = Settings.readIgnoredCategories()
        if currentUserWorkout != nil {
            if currentUserWorkout?.done == false {
                return currentUserWorkout!.category
            } else {
                return WorkoutCategory(rawValue: currentUserWorkout!.category)!.next(ignoredCategories).rawValue
            }
        }

        if lastUserWorkout != nil {
            return WorkoutCategory(rawValue: lastUserWorkout!.category)!.next(ignoredCategories).rawValue
        }

        return WorkoutCategory.Warmup.next(ignoredCategories).rawValue
    }

}
