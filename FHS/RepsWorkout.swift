//
//  RepsWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation


public struct RepsWorkout: RepsWorkoutProtocol, Hashable {

    let workout: WorkoutProtocol
    let rw_reps: NSNumber
    let rw_approx: NSNumber

    public var hashValue: Int {
        return self.workout.name().hashValue + rw_reps.hashValue
    }

    public init(workout: WorkoutProtocol, reps: NSNumber, approx: NSNumber) {
        self.workout = workout
        rw_reps = reps
        rw_approx = approx
    }

    public func repititions() -> NSNumber {
        return rw_reps
    }

    public func approx() -> NSNumber {
        return rw_approx
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

public func ==(lhs: RepsWorkout, rhs: RepsWorkout) -> Bool {
    return lhs.name() == rhs.name() && lhs.repititions() == rhs.repititions()
}