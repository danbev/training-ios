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
    func categories() -> [WorkoutCategory]
    func language() -> String
    func image() -> NSData
    func type() -> Type
    func restTime() -> NSNumber

}

public enum WorkoutCategory: String {
    case UpperBody = "Upperbody"
    case LowerBody = "Lowerbody"
    case Cardio = "Cardio"
    case Warmup = "Warmup"

    public func next() -> WorkoutCategory {
        switch self {
        case let .Warmup: return .UpperBody
        case let .UpperBody: return .LowerBody
        case let .LowerBody: return .Cardio
        case let .Cardio: return .UpperBody
        }
    }

    private static let lowerAndCardio: Set = [LowerBody, Cardio]
    private static let lowerAndUpper: Set = [UpperBody, LowerBody]
    private static let all: Set = [UpperBody, LowerBody, Cardio]

    public func next(ignore: Set<WorkoutCategory>) -> WorkoutCategory {
        if ignore.isEmpty {
            return next()
        }

        switch self {
        case let .Warmup:
            if !ignore.contains(.UpperBody) {
                return .UpperBody
            } else if !ignore.contains(.LowerBody) {
                return .LowerBody
            } else {
                return .Cardio
            }
        case let .UpperBody:
            if !ignore.contains(.LowerBody) {
                return .LowerBody
            } else if !ignore.contains(.Cardio) {
                return .Cardio
            } else {
                return .UpperBody
            }
        case let .LowerBody:
            if !ignore.contains(.Cardio) {
                return .Cardio
            } else if !ignore.contains(.UpperBody) {
                return .UpperBody
            } else {
                return .LowerBody
            }
        case let .Cardio:
            if !ignore.contains(.UpperBody) {
                return .UpperBody
            } else if !ignore.contains(.LowerBody) {
                return .LowerBody
            } else {
                return .Cardio
            }
        }
    }

    static func asCsvString(categories: [WorkoutCategory]) -> String {
        return ",".join(categories.map { $0.rawValue })
    }

}

public enum Type: String {
    case Reps = "reps"
    case Timed = "timed"
    case Interval = "interval"
    case Prebens = "prebens"

    static func asCsvString(types: [Type]) -> String {
        return ",".join(types.map { $0.rawValue })
    }
}
