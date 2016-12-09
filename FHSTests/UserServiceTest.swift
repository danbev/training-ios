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
        userService = UserService(coreDataStack: TestCoreDataStack.storesFromBundle(["User"], modelName: "User"))
    }

    func testNewUserWorkoutWithId() {
        let userWorkout = userService.newUserWorkout("testID").category(WorkoutCategory.UpperBody).save()
        XCTAssertEqual("testID", userWorkout.id)
    }

    func testNewUserWorkoutGeneratedId() {
        let userWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).save()
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
        let userWorkout = addJumpingJacks()
        XCTAssertEqual(1, userWorkout.workouts.count)
        let _ = userService.updateUserWorkout(userWorkout).addWorkout("Burpees").save()
        XCTAssertEqual(2, userWorkout.workouts.count)
    }

    func testNewUserWorkoutCompleted() {
        let userWorkout = addJumpingJacks()
        let _ = userService.updateUserWorkout(userWorkout).addWorkout("Burpees").done(true).save()
        XCTAssertTrue(userWorkout.done)
    }

    func testNewUserWorkoutAddSameWorkoutMultipleTimes() {
        let userWorkout = addJumpingJacks()
        XCTAssertEqual(1, userWorkout.workouts.count)
        let _ = userService.updateUserWorkout(userWorkout).addWorkout("Burpees").save()
        let _ = userService.updateUserWorkout(userWorkout).addWorkout("Burpees").save()
        let _ = userService.updateUserWorkout(userWorkout).addWorkout("Burpees").save()
        XCTAssertEqual(2, userWorkout.workouts.count)
    }

    func testFetchLastUserWorkoutNonExisting() {
        //XCTAssertNil(userService.fetchLatestUserWorkout());
    }

    func testFetchLastUserWorkout() {
        let _ = addJumpingJacks()
        XCTAssertNotNil(userService.fetchLatestUserWorkout());
    }

    func testUpdateWorkoutDuration() {
        let userWorkout = addJumpingJacks()
        XCTAssertEqual(Double(0.0), userWorkout.duration)
        let _ = userService.updateUserWorkout(userWorkout).addToDuration(60).save()
        XCTAssertEqual(Double(60.0), userWorkout.duration)
    }

    func testUpdateSingleWorkoutDuration() {
        let userWorkout = addJumpingJacks()
        XCTAssertEqual(Double(0.0), userService.fetchPerformedWorkoutInfo("JumpingJacks")!.duration)

        let _ = userService.updateUserWorkout(userWorkout).updateDuration("JumpingJacks", duration: 30).save()
        let workoutInfo = userService.fetchPerformedWorkoutInfo("JumpingJacks")!
        XCTAssertEqual(Double(30.0), workoutInfo.duration)
    }

    func testFetchPerformedWorkoutInfo() {
        let dateFormatter = UserServiceTest.dateFormatter()
        let augustFirst = dateFormatter.date(from: "August 1, 2015") as Date!
        let augustSecond = dateFormatter.date(from: "August 2, 2015") as Date!
        let augustThird = dateFormatter.date(from: "August 3, 2015") as Date!

        let firstWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustFirst!).save()
        let secondWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustSecond!).save()
        let thridWorkout = userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").date(augustThird!).save()
        let _ = userService.updateUserWorkout(firstWorkout).updateDuration("JumpingJacks", duration: 50).save()
        let _ = userService.updateUserWorkout(secondWorkout).updateDuration("JumpingJacks", duration: 40).save()
        let _ = userService.updateUserWorkout(thridWorkout).updateDuration("JumpingJacks", duration: 30).save()

        let workoutInfo = userService.fetchPerformedWorkoutInfo("JumpingJacks")!
        XCTAssertEqual(Double(30.0), workoutInfo.duration)
    }

    fileprivate func addJumpingJacks() -> UserWorkout {
        return userService.newUserWorkout().category(WorkoutCategory.UpperBody).addWorkout("JumpingJacks").save()
    }

    fileprivate class func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }

}
