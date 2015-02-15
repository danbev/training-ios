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
    func types() -> [Type]
    func language() -> String
    func image() -> NSData

}

public enum Type: String {
    case UpperBody = "upperbody"
    case LowerBody = "lowerbody"
    case Cardio = "cardio"
    case Warmup = "warmup"

    static func asCsvString(types: [Type]) -> String {
        return ",".join(types.map { $0.rawValue })
    }
}
