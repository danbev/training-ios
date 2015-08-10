//
//  Workout.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public struct Workout: WorkoutProtocol {

    let w_name: String
    let w_workoutName: String
    let w_workoutDescription: String
    let w_language: String
    let w_categories: String
    let w_videoUrl: String?
    let w_restTime: NSNumber
    let w_weights: Bool
    let w_dryGround: Bool

    public init(name: String, workoutName: String, workoutDescription: String, language: String, categories: String, videoUrl: String?, restTime: NSNumber, weights: Bool, dryGround: Bool) {
        w_name = name
        w_workoutName = workoutName
        w_workoutDescription = workoutDescription
        w_language = language
        w_categories = categories
        w_videoUrl = videoUrl
        w_restTime = restTime
        w_weights = weights
        w_dryGround = dryGround
    }

    public func name() -> String {
        return w_name
    }

    public func workoutName() -> String {
        return w_workoutName
    }

    public func workoutDescription() -> String {
        return w_workoutDescription
    }

    public func language() -> String {
        return language()
    }

    public func categories() -> String {
        return w_categories
    }

    public func videoUrl() -> String? {
        return w_videoUrl
    }

    public func restTime() -> NSNumber {
        return w_restTime
    }

    public func weights() -> Bool {
        return w_weights
    }

    public func dryGround() -> Bool {
        return w_dryGround
    }

}
