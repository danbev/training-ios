//
//  RepsWorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

protocol RepsWorkoutProtocol: WorkoutProtocol {

    var repititions: NSNumber { get }
    var approx: NSNumber { get }

}
