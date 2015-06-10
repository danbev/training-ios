//
//  WorkoutType.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public enum WorkoutType: String {
    case Reps = "reps"
    case Timed = "timed"
    case Interval = "interval"
    case Prebens = "prebens"

    static func asCsvString(types: [WorkoutType]) -> String {
        return ",".join(types.map { $0.rawValue })
    }
}
