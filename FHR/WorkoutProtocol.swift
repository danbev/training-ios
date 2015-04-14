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
    func workoutName() -> String
    func desc() -> String
    func categories() -> [Category]
    func language() -> String
    func image() -> NSData
    func type() -> Type
    func restTime() -> NSNumber

}

public enum Category: String {
    case UpperBody = "upperbody"
    case LowerBody = "lowerbody"
    case Cardio = "cardio"
    case Warmup = "warmup"

    public func next() -> Category {
        switch self {
        case let .Warmup: return .UpperBody
        case let .UpperBody: return .LowerBody
        case let .LowerBody: return .Cardio
        case let .Cardio: return .UpperBody
        }
    }

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
