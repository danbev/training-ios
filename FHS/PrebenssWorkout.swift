//
//  PrebenssWorkout.swift
//  FHS
//
//  Created by Daniel Bevenius on 10/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public struct PrebensWorkout: PrebensWorkoutProtocol {

    let workout: WorkoutProtocol
    let pw_workouts: [RepsWorkout]

    public init(workout: WorkoutProtocol, workouts: [RepsWorkout]) {
        self.workout = workout
        pw_workouts = workouts
    }

    func workouts() -> [RepsWorkout] {
        return pw_workouts
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