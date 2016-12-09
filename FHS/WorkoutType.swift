//
//  WorkoutType.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public enum WorkoutType: String {
    case Reps = "Repitition"
    case Timed = "Duration"
    case Interval = "Interval"
    case Prebens = "Prebens"

    static func asCsvString(_ types: [WorkoutType]) -> String {
        return types.map { $0.rawValue }.joined(separator: ",")
    }
}
