//
//  WorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol WorkoutProtocol {

    func name() -> String
    func workoutName() -> String
    func workoutDescription() -> String
    func language() -> String
    func categories() -> String
    func videoUrl() -> String?
    func restTime() -> NSNumber
    func weights() -> Bool
    func dryGround() -> Bool

}
