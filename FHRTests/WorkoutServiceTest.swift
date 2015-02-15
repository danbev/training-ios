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
        workoutService.addRepsWorkout("Burpees", desc: "Start from standing, squat down for a pushup, touch chest on ground, and jump up", reps: 100)
        workoutService.addRepsWorkout("Chop ups", desc: "Start from lying posistion and bring your legs towards you buttocks, then stand up", reps: 100)
        workoutService.addRepsWorkout("Get ups", desc: "long description...", reps: 50)
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
        println(workout!.name())
    }

}

