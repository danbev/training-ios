//
//  RepsWorkoutProtocol.swift
//  FHS
//
//  Created by Daniel Bevenius on 09/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol RepsWorkoutProtocol: WorkoutProtocol {

    func repititions() -> NSNumber
    func approx() -> NSNumber

}
