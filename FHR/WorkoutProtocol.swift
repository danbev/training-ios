//
//  WorkoutProtocol.swift
//  FHR
//
//  Created by Daniel Bevenius on 15/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation

public protocol WorkoutProtocol {
    func name() -> String
    func desc() -> String
    func category() -> String
    func language() -> String
    func image() -> NSData
}
