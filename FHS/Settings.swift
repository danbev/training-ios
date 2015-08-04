//
//  Settings.swift
//  FHR
//
//  Created by Daniel Bevenius on 08/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public struct Settings {
    public let weights: Bool
    public let dryGround: Bool
    public let warmup: Bool
    public let duration: Double
    public let ignoredCategories: Set<WorkoutCategory>
    public let stores: [String]
    static let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    public init(weights: Bool, dryGround: Bool, warmup: Bool, duration: Double, ignoredCategories: Set<WorkoutCategory>, stores: [String]) {
        self.weights = weights
        self.dryGround = dryGround
        self.warmup = warmup
        self.duration = duration
        self.ignoredCategories = ignoredCategories
        self.stores = stores
    }

    public static func settings() -> Settings {
        let weights = enabled("weights", defaultValue: true)
        let dryGround = enabled("dryGround", defaultValue: true)
        let warmup = enabled(WorkoutCategory.Warmup.rawValue, defaultValue: true)
        let duration = readDuration(2700)
        let stores = readStores()
        return Settings(weights: weights, dryGround: dryGround, warmup: warmup, duration: duration, ignoredCategories: readIgnoredCategories(), stores: stores)
    }

    public static func readIgnoredCategories() -> Set<WorkoutCategory> {
        var ignoredCategories = Set<WorkoutCategory>()
        if !enabled(WorkoutCategory.Warmup.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.Warmup)
        }
        if !enabled(WorkoutCategory.UpperBody.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.UpperBody)
        }
        if !enabled(WorkoutCategory.LowerBody.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.LowerBody)
        }
        if !enabled(WorkoutCategory.Cardio.rawValue, defaultValue: true) {
            ignoredCategories.insert(WorkoutCategory.Cardio)
        }
        return ignoredCategories
    }

    private static func enabled(keyName: String, defaultValue: Bool) -> Bool {
        if let value = userDefaults.objectForKey(keyName) as? Bool {
            return value
        }
        return defaultValue;
    }

    private static func readStores() -> [String] {
        if let stores = userDefaults.objectForKey("stores") as? [String] {
            println(stores)
            return stores
        } else {
            return ["FHS"]
        }
    }

    private static func readDuration(defaultValue: Int) -> Double {
        if let value = userDefaults.objectForKey("workoutDuration") as? Int {
            return Double(value * 60)
        }
        return Double(defaultValue)
    }
}
