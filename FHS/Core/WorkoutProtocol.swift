//
//  WorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol WorkoutProtocol {

    var name: String { get }
    var workoutName: String { get }
    var workoutDescription: String { get }
    var language: String { get }
    var categories: String { get }
    var videoUrl: String? { get }
    var restTime: NSNumber { get }
    var weights: NSNumber? { get }
    var dryGround: NSNumber? { get }

}
