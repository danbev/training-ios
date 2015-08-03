//
//  RuntimeWorkoutTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 18/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import FHS

class RuntimeWorkoutTests: XCTestCase {

    let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["FHS"])
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        self.workoutService = WorkoutService(context: coreDataStack.context)
    }

    func testInitWithLastUserWorkout() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)
        let runtime = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertNotNil(runtime.lastUserWorkout)
        XCTAssertNil(runtime.currentUserWorkout)
        */
    }

    func testInitWithLastUserWorkoutNotCompleted() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: false)
        let runtime = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertNotNil(runtime.lastUserWorkout)
        XCTAssertNotNil(runtime.currentUserWorkout)
        */
    }


    func testCategoryCurrentInProgress() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, runtimeWorkout.category())
        */
    }

    func testCategoryCurrentDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)
        workoutService.updateUserWorkout(currentId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, runtimeWorkout.category())
        */
    }

    func testCategoryCurrentNotDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)
        workoutService.updateUserWorkout(currentId, optionalWorkout: nil, workoutTime: 5.0, done: false)

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
        */
    }

    func testCategoryCurrentNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let runtimeWorkout = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
        */
    }

    func testCategoryCurrentAndLastNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let runtimeWorkout = RuntimeWorkout(lastUserWorkout: nil)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
    }

    func testWarmupCompleted() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        /*
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertTrue(runtimeWorkout.warmupCompleted(false, numberOfWarmups: 2))
        */
    }

}