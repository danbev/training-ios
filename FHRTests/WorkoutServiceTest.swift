//
//  WorkoutServiceTest.swift
//  FHR
//
//  Created by Daniel Bevenius on 08/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import FHR
import XCTest

class WorkoutServiceTest: XCTestCase {

    let coreDataStack: CoreDataStack = TestCoreDataStack()
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        self.workoutService = WorkoutService(context: coreDataStack.context)
    }

    func testAddWorkout() {
        workoutService.addRepsWorkout("Burpees", desc: "Start from standing, squat down for a pushup, touch chest on ground, and jump up", reps: 100, categories: WorkoutCategory.UpperBody)
        workoutService.addRepsWorkout("Chop ups", desc: "Start from lying posistion and bring your legs towards you buttocks, then stand up", reps: 100, categories: WorkoutCategory.UpperBody)
        workoutService.addRepsWorkout("Get ups", desc: "long description...", reps: 50, categories: WorkoutCategory.Cardio, WorkoutCategory.UpperBody)
        let optionalWorkouts = workoutService.fetchRepsWorkouts()!;
        XCTAssertEqual(3, optionalWorkouts.count)
    }

    func testAddDurationWorkout() {
        workoutService.addDurationWorkout("Chopups", desc: "Chopues", duration: 5)
        let optionalWorkouts = workoutService.fetchDurationWorkouts()!;
        XCTAssertEqual(1, optionalWorkouts.count)
    }

    func testAddIntervalWorkout() {
        let burpees = workoutService.addDurationWorkout("Burpees", desc: "Burpees", duration: 40)
        let chopups = workoutService.addDurationWorkout("Chopups", desc: "Chopups", duration: 20)
        workoutService.addIntervalWorkout("BurpeesInterval", desc: "Burpees and Chopups", work: burpees, rest: chopups)
        let optionalWorkouts = workoutService.fetchIntervalWorkouts()!;
        XCTAssertEqual(1, optionalWorkouts.count)
        XCTAssertEqual("BurpeesInterval", optionalWorkouts[0].parent.name())
        XCTAssertEqual("Burpees and Chopups", optionalWorkouts[0].parent.desc())
        XCTAssertEqual(burpees, optionalWorkouts[0].work)
        XCTAssertEqual(chopups, optionalWorkouts[0].rest)
    }

    func testLoadDatabase() {
        workoutService.loadDataIfNeeded();
        let burpees = workoutService.fetchWorkout("Burpees")!
        XCTAssertEqual("Burpees", burpees.name())
        XCTAssertNotNil(burpees.desc())
        XCTAssertEqual("en", burpees.language())
        XCTAssertNotNil(burpees.image())
        let chopups = workoutService.fetchWorkout("Chopups")!
        XCTAssertEqual("Chopups", chopups.name())
        XCTAssertNotNil(chopups.image())
    }
    func testFetchWarmup() {
        workoutService.loadDataIfNeeded();
        let workout = workoutService.fetchWarmup()
        XCTAssertNotNil(workout!.name())
    }

    func testFetchWarmupWithUserWorkout() {
        workoutService.loadDataIfNeeded();
        let workout = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: workout)
        if let warmup = workoutService.fetchWarmup(userWorkout) {
            XCTAssertNotEqual("Jumping Jacks", warmup.name())
        } else {
            XCTFail("A warmup should have been found.")
        }
    }

    func testFetchLatestWorkoutNoWorkoutsPerformed() {
        workoutService.loadDataIfNeeded();
        let optionalLatest = workoutService.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTFail("No user workouts should exist")
        }
    }

    func testFetchLatestWorkout() {
        workoutService.loadDataIfNeeded();
        let workout = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: workout)

        let optionalLatest = workoutService.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTAssertNotNil(userWorkout.date)
            XCTAssertEqual(false, userWorkout.done.boolValue)
            XCTAssertEqual(1, userWorkout.workouts.count)
            //XCTAssertEqual("JumpingJacks", userWorkout.workouts.anyObject()!.name())
            XCTAssertEqual("JumpingJacks", userWorkout.workouts.lastObject!.name!)
        }
    }

    func testFetchWorkout() {
        workoutService.loadDataIfNeeded();
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: warmup)
        let workout1 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout)
        XCTAssertNotNil(workout1!.name())
        workoutService.updateUserWorkout(id, optionalWorkout: workout1!, workoutTime: 1.0)
        let workout2 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout)
        XCTAssertNotEqual(workout2!.name(), workout1!.name())
        workoutService.updateUserWorkout(id, optionalWorkout: workout2!, workoutTime: 1.0)
        let workout3 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout)
        /*
        if let userWorkout = workout3 {
            XCTFail("There are currently no more workouts.")
        }
        */
    }

    func testSaveUserWorkout() {
        workoutService.loadDataIfNeeded();
        let workout = workoutService.fetchWorkout("Burpees")!
        let id = NSUUID().UUIDString
        workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: workout)
        let userWorkouts = workoutService.fetchUserWorkouts()!
        let userWorkout = userWorkouts[0]
        XCTAssertEqual(id, userWorkout.id)
        XCTAssertNotNil(userWorkout.date)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category)
        XCTAssertNotNil(userWorkout.workouts)
    }

    func testUpdateUserWorkout() {
        workoutService.loadDataIfNeeded();
        let workout1 = workoutService.fetchWorkout("Burpees")!
        let id = NSUUID().UUIDString
        workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: workout1)

        let workout2 = workoutService.fetchWorkout("Getups")!
        workoutService.updateUserWorkout(id, optionalWorkout: workout2, workoutTime: 1.0)

        let userWorkout = workoutService.fetchLatestUserWorkout()!
        XCTAssertEqual(2, userWorkout.workouts.count);
        XCTAssertEqual(id, userWorkout.id)
        XCTAssertNotNil(userWorkout.date)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category)
    }

    func testFetchPrebensWorkouts() {
        workoutService.loadDataIfNeeded();
        let prebensWorkouts = workoutService.fetchPrebensWorkouts()!
        XCTAssertEqual(2, prebensWorkouts.count);
        XCTAssertEqual(Type.Prebens, prebensWorkouts[0].type());
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, prebensWorkouts[0].categories()[0].rawValue);
        XCTAssertEqual(7, prebensWorkouts[0].workouts.count);
        for w in prebensWorkouts[0].workouts {
            println(w.name())
        }
    }
}

