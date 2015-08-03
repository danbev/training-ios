//
//  CoreDataStackTest.swift
//  FHS
//
//  Created by Daniel Bevenius on 29/07/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import FHS
import XCTest

class CoreDataStackTest: XCTestCase {

    func testFHSDataStore() {
        let fhsStack: CoreDataStack = CoreDataStack(modelName: "FHS", storeNames: ["FHS"])
        let ws = WorkoutService(context: fhsStack.context)
        let jumpingJacks = ws.fetchWorkout("JumpingJacks")!
        XCTAssertEqual("JumpingJacks", jumpingJacks.name)
        ws.importData(NSBundle.mainBundle().URLForResource("workouts", withExtension: "json")!)
        let jumpingJacks2 = ws.fetchWorkout("JumpingJacks")!
        println("-> \(jumpingJacks2.name)")
        XCTAssertEqual("JumpingJacks", jumpingJacks.name)
    }
    
}