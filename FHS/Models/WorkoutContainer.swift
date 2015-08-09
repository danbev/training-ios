//
//  WorkoutContainer.swift
//  FHS
//
//  Created by Daniel Bevenius on 08/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public class WorkoutContainer {
    public let name: String
    public let workoutName: String
    public let workoutDescription: String
    public let language: String
    public let categories: String
    public let videoUrl: String?
    public let restTime: NSNumber
    public let weights: NSNumber?
    public let dryGround: NSNumber?

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
