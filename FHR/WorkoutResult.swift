//
//  WorkoutResult.swift
//  FHR
//
//  Created by Daniel Bevenius on 16/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class WorkoutResult {

    public let workout: Workout
    public let duration: Int

    public init(workout: Workout, duration: Int) {
        self.workout = workout
        self.duration = duration
    }

}
