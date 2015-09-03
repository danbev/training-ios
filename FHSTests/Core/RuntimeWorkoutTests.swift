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

    let coreDataStack: CoreDataStack = TestCoreDataStack.storesFromBundle(["FHS"], modelName: "FHS")
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        self.workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack.storesFromBundle(["User"], modelName: "User")))
    }

    func testInitWithLastUserWorkout() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true).save()
        let runtime = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertNotNil(runtime.lastUserWorkout)
        XCTAssertNil(runtime.currentUserWorkout)
    }

    func testInitWithLastUserWorkoutNotCompleted() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(false).save()
        let runtime = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertNotNil(runtime.lastUserWorkout)
        XCTAssertNotNil(runtime.currentUserWorkout)
    }


    func testCategoryCurrentInProgress() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true).save()

        let currentId = NSUUID().UUIDString
        let currentWorkout = userService.newUserWorkout(currentId).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, runtimeWorkout.category())
    }

    func testCategoryCurrentDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true).save()

        let currentId = NSUUID().UUIDString
        let currentWorkout = userService.newUserWorkout(currentId).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()
        userService.updateUserWorkout(currentWorkout).addToDuration(5.0).done(true).save()

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, runtimeWorkout.category())
    }

    func testCategoryCurrentNotDone() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true)

        let currentId = NSUUID().UUIDString
        let currentWorkout = userService.newUserWorkout(currentId).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()
        userService.updateUserWorkout(currentWorkout).addToDuration(5.0).done(false).save()

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
    }

    func testCategoryCurrentNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!

        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true).save()

        let runtimeWorkout = RuntimeWorkout(lastUserWorkout: lastWorkout)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
    }

    func testCategoryCurrentAndLastNil() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!

        let runtimeWorkout = RuntimeWorkout(lastUserWorkout: nil)
        XCTAssertEqual(WorkoutCategory.Warmup.next().rawValue, runtimeWorkout.category())
    }

    func testWarmupCompleted() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkoutProtocol("JumpingJacks")!
        let lastId = NSUUID().UUIDString
        let userService = workoutService.getUserService()
        let lastWorkout = userService.newUserWorkout(lastId).category(WorkoutCategory.Cardio).addWorkout(warmup).save()
        userService.updateUserWorkout(lastWorkout).addToDuration(5.0).done(true).save()

        let currentId = NSUUID().UUIDString
        let currentWorkout = userService.newUserWorkout(currentId).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()

        let runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentWorkout, lastUserWorkout: lastWorkout)
        XCTAssertTrue(runtimeWorkout.warmupCompleted(false, numberOfWarmups: 2))
    }

}