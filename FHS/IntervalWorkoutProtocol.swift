//
//  IntervalWorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol IntervalWorkoutProtocol: WorkoutProtocol {

    func work() -> DurationWorkoutProtocol
    func rest() -> DurationWorkoutProtocol
    func intervals() -> NSNumber 
    
}
