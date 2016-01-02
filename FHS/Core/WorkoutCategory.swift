//
//  WorkoutProtocol.swift
//  FHR
//
//  Created by Daniel Bevenius on 15/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public enum WorkoutCategory: String {
    case UpperBody = "Upperbody"
    case LowerBody = "Lowerbody"
    case Cardio = "Cardio"
    case Warmup = "Warmup"

    public func next() -> WorkoutCategory {
        switch self {
        case .Warmup: return .UpperBody
        case .UpperBody: return .LowerBody
        case .LowerBody: return .Cardio
        case .Cardio: return .UpperBody
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
        case .Warmup:
            if !ignore.contains(.UpperBody) {
                return .UpperBody
            } else if !ignore.contains(.LowerBody) {
                return .LowerBody
            } else {
                return .Cardio
            }
        case .UpperBody:
            if !ignore.contains(.LowerBody) {
                return .LowerBody
            } else if !ignore.contains(.Cardio) {
                return .Cardio
            } else {
                return .UpperBody
            }
        case .LowerBody:
            if !ignore.contains(.Cardio) {
                return .Cardio
            } else if !ignore.contains(.UpperBody) {
                return .UpperBody
            } else {
                return .LowerBody
            }
        case .Cardio:
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
        return categories.map { $0.rawValue }.joinWithSeparator(",")
    }

}
