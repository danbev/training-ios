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
    private static let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

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

    public func category() -> String {
        let ignoredCategories = RuntimeWorkout.readIgnoredCategories()
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

    public class func readIgnoredCategories() -> Set<WorkoutCategory> {
        var ignoredCategories = Set<WorkoutCategory>()
        if !RuntimeWorkout.enabled(WorkoutCategory.UpperBody.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.UpperBody)
        }
        if !RuntimeWorkout.enabled(WorkoutCategory.LowerBody.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.LowerBody)
        }
        if !RuntimeWorkout.enabled(WorkoutCategory.Cardio.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.Cardio)
        }
        return ignoredCategories
    }

    public class func settings() -> (weights: Bool, dryGround: Bool, warmup: Bool) {
        let weights = enabled("weights", defaultValue: true)
        let dryGround = enabled("dryGround", defaultValue: true)
        let warmup = enabled("warmup", defaultValue: true)
        return (weights, dryGround, warmup)
    }

    public class func readDurationSetting() -> Double {
        if let value = RuntimeWorkout.userDefaults.objectForKey("workoutDuration") as? Int {
            return Double(value * 60)
        }
        return Double(2700)
    }

    private class func enabled(keyName: String, defaultValue: Bool) -> Bool {
        if let value = RuntimeWorkout.userDefaults.objectForKey(keyName) as? Bool {
            return value
        }
        return defaultValue;
    }
}
