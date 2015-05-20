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

    func testAddRepsWorkout() {
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
        workoutService.loadDataIfNeeded()
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
        workoutService.loadDataIfNeeded()
        let workout = workoutService.fetchWarmup()
        XCTAssertNotNil(workout!.name())
    }

    func testFetchWarmupWithUserWorkout() {
        workoutService.loadDataIfNeeded()
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
        workoutService.loadDataIfNeeded()
        let optionalLatest = workoutService.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTFail("No user workouts should exist")
        }
    }

    func testFetchLatestWorkout() {
        workoutService.loadDataIfNeeded()
        let workout = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: workout)

        let optionalLatest = workoutService.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTAssertNotNil(userWorkout.date)
            XCTAssertEqual(false, userWorkout.done.boolValue)
            XCTAssertEqual(1, userWorkout.workouts.count)
            XCTAssertEqual("JumpingJacks", userWorkout.workouts.lastObject!.name!)
        }
    }

    func testFetchWorkout() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: warmup)

        let workout1 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout1!.name())
        workoutService.updateUserWorkout(id, optionalWorkout: workout1!, workoutTime: 1.0)

        let workout2 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotEqual(workout2!.name(), workout1!.name())
        workoutService.updateUserWorkout(id, optionalWorkout: workout2!, workoutTime: 1.0)

        let workout3 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: true)
        XCTAssertNotNil(workout3)
    }

    func testFetchWorkoutDryGround() {
        workoutService.loadDataIfNeeded()
        let warmup = workoutService.fetchWorkout("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = workoutService.saveUserWorkout(id, category: WorkoutCategory.UpperBody, workout: warmup)

        let workout1 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout1!.name())
        workoutService.updateUserWorkout(id, optionalWorkout: workout1!, workoutTime: 1.0)
        let workout2 = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout2!.name())
    }

    func testSaveUserWorkout() {
        workoutService.loadDataIfNeeded()
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
        workoutService.loadDataIfNeeded()
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
        workoutService.loadDataIfNeeded()
        let prebensWorkouts = workoutService.fetchPrebensWorkouts()!
        XCTAssertEqual(2, prebensWorkouts.count);
        XCTAssertEqual(Type.Prebens, prebensWorkouts[0].type());
        XCTAssertEqual(7, prebensWorkouts[0].workouts.count);
        for p in prebensWorkouts {
            let category = WorkoutCategory(rawValue: p.modelCategories)!
            switch category {
            case .UpperBody :
                XCTAssertEqual("Bicep curl", p.workouts[0].workoutName())
                XCTAssertEqual("Front bench press", p.workouts[1].workoutName())
                XCTAssertEqual("Military press", p.workouts[2].workoutName())
                XCTAssertEqual("Ryck", p.workouts[3].workoutName())
                XCTAssertEqual("Hakdrag", p.workouts[4].workoutName())
                XCTAssertEqual("Standing rowing", p.workouts[5].workoutName())
                XCTAssertEqual("Squats", p.workouts[6].workoutName())
            case .LowerBody :
                XCTAssertEqual("Russians", p.workouts[0].workoutName())
                XCTAssertEqual("Squats", p.workouts[1].workoutName())
                XCTAssertEqual("Flat foot jumps", p.workouts[2].workoutName())
                XCTAssertEqual("Lunges", p.workouts[3].workoutName())
                XCTAssertEqual("Lunge jumps", p.workouts[4].workoutName())
                XCTAssertEqual("Marklyft", p.workouts[5].workoutName())
                XCTAssertEqual("Stallion Burpees", p.workouts[6].workoutName())
            default:
                println("should not happen yet.")
            }
        }
    }

    func testNewUserworkoutNonExistingWorkout() {
        workoutService.loadDataIfNeeded()
        let userWorkout = workoutService.newUserWorkout(nil, ignoredCategories: [])!
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category);
        XCTAssertEqual(1, userWorkout.workouts.count);
        XCTAssertNotNil(userWorkout)
    }

    func testNewUserworkout() {
        workoutService.loadDataIfNeeded()
        let lastWorkout = workoutService.newUserWorkout(nil, ignoredCategories: [])!
        let userWorkout = workoutService.newUserWorkout(lastWorkout, ignoredCategories: [])!
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, userWorkout.category);
        XCTAssertNotEqual(lastWorkout.workouts[0].name, userWorkout.workouts[0].name)
    }
}

