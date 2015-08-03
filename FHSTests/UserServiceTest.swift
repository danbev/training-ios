//
//  UserDataTest.swift
//  FHS
//
//  Created by Daniel Bevenius on 01/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import FHS
import XCTest

class UserServiceTest: XCTestCase {

    var userService: UserService!

    override func setUp() {
        super.setUp()
        userService = UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"]))
    }

    func testNewUserWorkoutWithId() {
        var userWorkout = userService.newUserWorkout("testID").category(WorkoutCategory.UpperBody).save()
        XCTAssertEqual("testID", userWorkout.id)
    }

    func testNewUserWorkoutGeneratedId() {
        var userWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).save()
        XCTAssertNotNil(userWorkout.id)
    }

    func testNewUserWorkoutCategory() {
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, addJumpingJacks().category)
    }

    func testNewUserWorkoutDate() {
        XCTAssertNotNil(addJumpingJacks().date)
    }

    func testNewUserWorkoutDone() {
        XCTAssertFalse(addJumpingJacks().done)
    }

    func testNewUserWorkoutAdded() {
        var userWorkout = addJumpingJacks()
        XCTAssertEqual(1, userWorkout.workouts.count)
        userService.updateUserWorkout(userWorkout).addWorkout("Burpees").save()
        XCTAssertEqual(2, userWorkout.workouts.count)
    }

    func testNewUserWorkoutCompleted() {
        var userWorkout = addJumpingJacks()
        userService.updateUserWorkout(userWorkout).addWorkout("Burpees").done(true).save()
        XCTAssertTrue(userWorkout.done)
    }

    func testFetchLastUserWorkoutNonExisting() {
        XCTAssertNil(userService.fetchLatestUserWorkout());
    }

    func testFetchLastUserWorkout() {
        addJumpingJacks()
        XCTAssertNotNil(userService.fetchLatestUserWorkout());
    }

    func testUpdateDuration() {
        let userWorkout = addJumpingJacks()
        XCTAssertEqual(Double(0.0), userService.fetchPerformedWorkoutInfo("JumpingJacks")!.duration)

        userService.updateUserWorkout(userWorkout).updateDuration("JumpingJacks", duration: 30).save()
        let workoutInfo = userService.fetchPerformedWorkoutInfo("JumpingJacks")!
        XCTAssertEqual(Double(30.0), workoutInfo.duration)
    }

    func testFetchPerformedWorkoutInfo() {
        var dateFormatter = UserServiceTest.dateFormatter()
        let augustFirst = dateFormatter.dateFromString("August 1, 2015") as NSDate!
        let augustSecond = dateFormatter.dateFromString("August 2, 2015") as NSDate!
        let augustThird = dateFormatter.dateFromString("August 3, 2015") as NSDate!

        let firstWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustFirst).save()
        let secondWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustSecond).save()
        let thridWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustThird).save()
        userService.updateUserWorkout(firstWorkout).updateDuration("JumpingJacks", duration: 50).save()
        userService.updateUserWorkout(secondWorkout).updateDuration("JumpingJacks", duration: 40).save()
        userService.updateUserWorkout(thridWorkout).updateDuration("JumpingJacks", duration: 30).save()

        let workoutInfo = userService.fetchPerformedWorkoutInfo("JumpingJacks")!
        XCTAssertEqual(Double(30.0), workoutInfo.duration)
    }

    private func addJumpingJacks() -> UserWorkout {
        return userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").save()
    }

    private class func dateFormatter() -> NSDateFormatter {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }

}
