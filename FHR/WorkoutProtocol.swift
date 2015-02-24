//
//  WorkoutProtocol.swift
//  FHR
//
//  Created by Daniel Bevenius on 15/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol WorkoutProtocol {
    func name() -> String
    func desc() -> String
    func categories() -> [Category]
    func language() -> String
    func image() -> NSData
    func type() -> Type

}

public enum Category: String {
    case UpperBody = "upperbody"
    case LowerBody = "lowerbody"
    case Cardio = "cardio"
    case Warmup = "warmup"

    static func asCsvString(categories: [Category]) -> String {
        return ",".join(categories.map { $0.rawValue })
    }
}

public enum Type: String {
    case Reps = "reps"
    case Timed = "timed"
    case Interval = "interval"

    static func asCsvString(types: [Type]) -> String {
        return ",".join(types.map { $0.rawValue })
    }
}
