//
//  DurationWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 10/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public struct DurationWorkout: DurationWorkoutProtocol {

    let workout: WorkoutProtocol
    let dw_duration: NSNumber

    public init(workout: WorkoutProtocol, duration: NSNumber) {
        self.workout = workout
        dw_duration = duration
    }

    public func duration() -> NSNumber {
        return dw_duration
    }

    public func name() -> String {
        return workout.name()
    }

    public func workoutName() -> String {
        return workout.workoutName()
    }

    public func workoutDescription() -> String {
        return workout.workoutDescription()
    }

    public func language() -> String {
        return workout.language()
    }

    public func categories() -> String {
        return workout.categories()
    }

    public func videoUrl() -> String? {
        return workout.videoUrl()
    }

    public func restTime() -> NSNumber {
        return workout.restTime()
    }

    public func weights() -> Bool {
        return workout.weights()
    }

    public func dryGround() -> Bool {
        return workout.dryGround()
    }
    
    
}
