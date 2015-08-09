//
//  IntervalWorkoutContainer.swift
//  FHS
//
//  Created by Daniel Bevenius on 08/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class IntervalWorkoutContainer: WorkoutContainer {

    public let duration: NSNumber

    init(name: String, workoutName: String, workoutDescription: String, language: String, categories: String, videoUrl: String?, restTime: NSNumber, weights: NSNumber?, dryGround: NSNumber, duration: NSNumber) {
        self.duration = duration
        super.init(name: name, workoutName: workoutName, workoutDescription: workoutDescription, language: language, categories: categories, videoUrl: videoUrl, restTime: restTime, weights: weights, dryGround: dryGround)
    }
}
