//
//  WorkoutTask.swift
//  FHR
//
//  Created by Daniel Bevenius on 16/11/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import Foundation

public class WorkoutTask : Printable {

    public let name: String
    public let reps: Int
    public let desc: String

    public init(name: String, reps: Int, desc: String) {
        self.name = name
        self.reps = reps
        self.desc = desc
    }

    public var description: String {
        return "WorkoutTask[name=\(name), reps=\(reps), desc=\(desc)"
    }

}
