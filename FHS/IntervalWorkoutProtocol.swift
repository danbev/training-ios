//
//  IntervalWorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

protocol IntervalWorkoutProtocol: WorkoutProtocol {

    var work: DurationWorkoutProtocol { get }
    var rest: DurationWorkoutProtocol { get }
    var intervals: NSNumber { get }
    
}
