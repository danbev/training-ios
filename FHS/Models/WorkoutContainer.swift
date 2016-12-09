//
//  WorkoutContainer.swift
//  FHS
//
//  Created by Daniel Bevenius on 08/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

open class WorkoutContainer {
    open let name: String
    open let workoutName: String
    open let workoutDescription: String
    open let language: String
    open let categories: String
    open let videoUrl: String?
    open let restTime: NSNumber
    open let weights: NSNumber?
    open let dryGround: NSNumber?

    public init(name: String, workoutName: String, workoutDescription: String, language: String, categories: String, videoUrl: String?, restTime: NSNumber, weights: NSNumber?, dryGround: NSNumber) {
        self.name = name
        self.workoutName = workoutName
        self.workoutDescription = workoutDescription
        self.language = language
        self.categories = categories
        self.videoUrl = videoUrl
        self.restTime = restTime
        self.weights = weights
        self.dryGround = dryGround
    }

}
