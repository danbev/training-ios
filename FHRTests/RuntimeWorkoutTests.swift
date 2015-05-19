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
import FHR

class RuntimeWorkoutTests: XCTestCase {

    let coreDataStack: CoreDataStack = TestCoreDataStack()
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        self.workoutService = WorkoutService(context: coreDataStack.context)
    }

    func testInitWithLastUserWorkout() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)
        let runtime = RuntimeWorkout(lastWorkout: lastWorkout)
        XCTAssertNotNil(runtime.lastWorkout)
        XCTAssertNil(runtime.currentWorkout)
    }

    func testCategoryCurrentInProgress() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)

        let runtimeWorkout = RuntimeWorkout(currentWorkout: currentWorkout, lastWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, runtimeWorkout.category([]))
    }

    func testCategoryCurrentDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)
        workoutService.updateUserWorkout(currentId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let runtimeWorkout = RuntimeWorkout(currentWorkout: currentWorkout, lastWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory(rawValue: currentWorkout.category)!.rawValue, runtimeWorkout.category([]))
    }

    func testCategoryCurrentNotDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = workoutService.saveUserWorkout(currentId, category: WorkoutCategory.UpperBody, workout: warmup)
        workoutService.updateUserWorkout(currentId, optionalWorkout: nil, workoutTime: 5.0, done: false)

        let runtimeWorkout = RuntimeWorkout(currentWorkout: currentWorkout, lastWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category([]))
    }

    func testCategoryCurrentNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let lastWorkout = workoutService.saveUserWorkout(lastId, category: WorkoutCategory.Cardio, workout: warmup)
        workoutService.updateUserWorkout(lastId, optionalWorkout: nil, workoutTime: 5.0, done: true)

        let runtimeWorkout = RuntimeWorkout(lastWorkout: lastWorkout)
        println(runtimeWorkout.category([]))
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category([]))
    }

    func testCategoryCurrentAndLastNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!

        let runtimeWorkout = RuntimeWorkout(lastWorkout: nil)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category([]))
    }

}