//
//  IntervalWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 10/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public struct IntervalWorkout: IntervalWorkoutProtocol {

    let workout: WorkoutProtocol
    let iw_work: DurationWorkoutProtocol
    let iw_rest: DurationWorkoutProtocol
    let iw_intervals: NSNumber

    public init(workout: WorkoutProtocol, work: DurationWorkoutProtocol, rest: DurationWorkoutProtocol, intervals: NSNumber) {
        self.workout = workout
        iw_work = work
        iw_rest = rest
        iw_intervals = intervals
    }

    public func work() -> DurationWorkoutProtocol {
        return iw_work
    }

    public func rest() -> DurationWorkoutProtocol {
        return iw_rest
    }

    public func intervals() -> NSNumber {
        return iw_intervals
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
