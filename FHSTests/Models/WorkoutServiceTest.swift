//
//  WorkoutServiceTest.swift
//  FHR
//
//  Created by Daniel Bevenius on 08/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import FHS
import XCTest

class WorkoutServiceTest: XCTestCase {

    let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["FHS"])
    var ws: WorkoutService!

    override func setUp() {
        super.setUp()
        self.ws = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"])))
    }

    func testAddRepsWorkout() {
        ws.reps(100)
            .name("Burpees")
            .workoutName("100 Burpees")
            .description("Start from standing, squat down for a pushup, touch chest on ground, and jump up")
            .language("en")
            .weights(false)
            .dryGround(false)
            .approx(300)
            .postRestTime(60)
            .categories(WorkoutCategory.UpperBody.rawValue)
            .saveRepsWorkout()
        ws.reps(100)
            .name("Chopups")
            .workoutName("100 Chop ups")
            .description("Start from lying posistion and bring your legs towards you buttocks, then stand up")
            .language("en")
            .weights(false)
            .dryGround(false)
            .approx(300)
            .postRestTime(60)
            .categories(WorkoutCategory.UpperBody)
            .saveRepsWorkout()
        ws.reps(100)
            .name("Getups")
            .workoutName("100 Get ups")
            .description("Some description...")
            .language("en")
            .weights(false)
            .dryGround(false)
            .approx(300)
            .postRestTime(60)
            .categories(WorkoutCategory.Cardio, WorkoutCategory.UpperBody)
            .saveRepsWorkout()
        let optionalWorkouts = ws.fetchRepsWorkouts()!;
        XCTAssertEqual(3, optionalWorkouts.count)
        let savedChopups = optionalWorkouts.filter( { (w) in w.workoutName == "100 Chop ups" })[0]
        XCTAssertEqual("Chopups", savedChopups.name)
        XCTAssertEqual("100 Chop ups", savedChopups.workoutName)
        XCTAssertEqual("en", savedChopups.language)
        XCTAssertFalse(savedChopups.weights!.boolValue)
        XCTAssertFalse(savedChopups.dryGround!.boolValue)
        XCTAssertNotNil(savedChopups.workoutDescription)
        XCTAssertEqual(300, savedChopups.approx)
        XCTAssertEqual(60, savedChopups.restTime)
    }

    func testAddDurationWorkout() {
        ws.duration(5)
            .name("Chopups")
            .workoutName("Get ups")
            .description("Some description...")
            .language("en")
            .weights(false)
            .dryGround(false)
            .postRestTime(60)
            .categories(WorkoutCategory.Cardio, WorkoutCategory.UpperBody)
            .saveDurationWorkout()
        let optionalWorkouts = ws.fetchDurationWorkouts()!;
        XCTAssertEqual(1, optionalWorkouts.count)
    }

    func testAddIntervalWorkout() {
        let burpees = ws.duration(40)
                        .name("Burpees")
                        .workoutName("Burpees")
                        .description("Burpees..")
                        .language("en")
                        .weights(false)
                        .dryGround(false)
                        .postRestTime(60)
                        .categories(WorkoutCategory.Cardio, WorkoutCategory.UpperBody)
                        .saveDurationWorkout()
        let chopups = ws.duration(40)
                        .name("Chopups")
                        .workoutName("Chopups")
                        .description("Start from lying position..")
                        .language("en")
                        .weights(false)
                        .dryGround(false)
                        .postRestTime(60)
                        .categories(WorkoutCategory.Cardio, WorkoutCategory.UpperBody)
                        .saveDurationWorkout()
        let interval = ws.interval(burpees, duration: burpees.duration().integerValue)
                .rest(chopups, duration: chopups.duration().integerValue)
                .name("BurpeesInterval")
                .workoutName("BurpeesInterval")
                .intervals(5)
                .description("Burpees and Chopups")
                .language("en")
                .weights(false)
                .dryGround(false)
                .categories(WorkoutCategory.Cardio)
                .saveIntervalWorkout()
        let optionalWorkouts = ws.fetchIntervalWorkouts()!;
        XCTAssertEqual(1, optionalWorkouts.count)
        let intervalWorkout = optionalWorkouts.filter( { (workout) in workout.workoutName == "BurpeesInterval" })[0]
        XCTAssertNotNil(intervalWorkout)
        XCTAssertEqual("BurpeesInterval", intervalWorkout.workoutName)
        XCTAssertEqual("Burpees and Chopups", intervalWorkout.workoutDescription)
        XCTAssertEqual(burpees.workoutName(), intervalWorkout.work.workoutName)
        XCTAssertEqual(chopups.workoutName(), intervalWorkout.rest.workoutName)
    }

    func testLoadDatabase() {
        ws.loadDataIfNeeded()
        let burpees = ws.fetchWorkoutProtocol("Burpees")!
        XCTAssertEqual("Burpees", burpees.name())
        XCTAssertNotNil(burpees.workoutDescription())
        XCTAssertEqual("en", burpees.language())
        XCTAssertNotNil(burpees.videoUrl())
        let chopups = ws.fetchWorkoutProtocol("Chopups")!
        XCTAssertEqual("Chopups", chopups.name())
        XCTAssertNotNil(chopups.videoUrl())
    }

    func testFetchWarmup() {
        ws.loadDataIfNeeded()
        let workout = ws.fetchWarmupProtocol()
        XCTAssertNotNil(workout!.name())
    }

    func testFetchWarmupWithUserWorkout() {
        ws.loadDataIfNeeded()
        let workout = ws.fetchWorkoutProtocol("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = ws.getUserService().newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(workout).save()
        if let warmup = ws.fetchWarmupProtocol(userWorkout) {
            XCTAssertNotEqual("Jumping Jacks", warmup.name())
        } else {
            XCTFail("A warmup should have been found.")
        }
    }

    func testFetchLatestWorkoutNoWorkoutsPerformed() {
        ws.loadDataIfNeeded()
        let optionalLatest = ws.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTFail("No user workouts should exist")
        }
    }

    func testFetchLatestWorkout() {
        ws.loadDataIfNeeded()
        let workout = ws.fetchWorkoutProtocol("JumpingJacks")!
        let id = NSUUID().UUIDString
        ws.getUserService().newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(workout.name())

        let optionalLatest = ws.fetchLatestUserWorkout()
        if let userWorkout = optionalLatest {
            XCTAssertNotNil(userWorkout.date)
            XCTAssertEqual(false, userWorkout.done.boolValue)
            XCTAssertEqual(1, userWorkout.workouts.count)
            XCTAssertEqual("JumpingJacks", userWorkout.workouts.lastObject!.name!)
        }
    }

    func testFetchWorkout() {
        ws.loadDataIfNeeded()
        let us = ws.getUserService()
        let warmup = ws.fetchWorkoutProtocol("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = us.newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()

        let workout1 = ws.fetchWorkoutProtocol(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout1!.name())
        us.updateUserWorkout(userWorkout).addWorkout(workout1).addToDuration(1.0).save()

        let workout2 = ws.fetchWorkoutProtocol(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotEqual(workout2!.name(), workout1!.name())
        us.updateUserWorkout(userWorkout).addWorkout(workout2).addToDuration(1.0).save()

        let workout3 = ws.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: true)
        XCTAssertNotNil(workout3)
    }

    func testFetchWorkoutDryGround() {
        ws.loadDataIfNeeded()
        let warmup = ws.fetchWorkoutProtocol("JumpingJacks")!
        let id = NSUUID().UUIDString
        let userWorkout = ws.getUserService().newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(warmup).save()

        let workout1 = ws.fetchWorkoutProtocol(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout1!.name())
        ws.getUserService().updateUserWorkout(userWorkout).addWorkout(workout1).addToDuration(1.0).save()
        let workout2 = ws.fetchWorkoutProtocol(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: userWorkout, weights: true, dryGround: false)
        XCTAssertNotNil(workout2!.name())
    }

    func testSaveUserWorkout() {
        ws.loadDataIfNeeded()
        let workout = ws.fetchWorkoutProtocol("Burpees")!
        let id = NSUUID().UUIDString
        let userWorkout = ws.getUserService().newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(workout).save()
        XCTAssertEqual(id, userWorkout.id)
        XCTAssertNotNil(userWorkout.date)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category)
        XCTAssertNotNil(userWorkout.workouts)
    }

    func testUpdateUserWorkout() {
        ws.loadDataIfNeeded()
        let workout1 = ws.fetchWorkoutProtocol("Burpees")!
        let id = NSUUID().UUIDString
        let userWorkout = ws.getUserService().newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(workout1).save()

        let workout2 = ws.fetchWorkoutProtocol("Getups")!
        ws.getUserService().updateUserWorkout(userWorkout).addWorkout(workout2).addToDuration(1.0)

        let fetchedUserWorkout = ws.getUserService().fetchLatestUserWorkout()!
        XCTAssertEqual(2, fetchedUserWorkout.workouts.count);
        XCTAssertEqual(id, fetchedUserWorkout.id)
        XCTAssertNotNil(fetchedUserWorkout.date)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, fetchedUserWorkout.category)
    }

    func testFetchPrebensWorkouts() {
        ws.loadDataIfNeeded()
        let prebensWorkouts = ws.fetchPrebensWorkouts()!
        XCTAssertEqual(2, prebensWorkouts.count);
        XCTAssertEqual(WorkoutType.Prebens.rawValue, prebensWorkouts[0].type);
        XCTAssertEqual(7, prebensWorkouts[0].workouts.count);
        for p in prebensWorkouts {
            let category = WorkoutCategory(rawValue: p.categories)!
            switch category {
            case .UpperBody :
                XCTAssertEqual("Bicep curl", p.workouts[0].workoutName)
                XCTAssertEqual("Front bench press", p.workouts[1].workoutName)
                XCTAssertEqual("Military press", p.workouts[2].workoutName)
                XCTAssertEqual("Snatch", p.workouts[3].workoutName)
                XCTAssertEqual("Hakdrag", p.workouts[4].workoutName)
                XCTAssertEqual("Standing rowing", p.workouts[5].workoutName)
                XCTAssertEqual("Squats", p.workouts[6].workoutName)
            case .LowerBody :
                XCTAssertEqual("Russians", p.workouts[0].workoutName)
                XCTAssertEqual("Squats", p.workouts[1].workoutName)
                XCTAssertEqual("Flat foot jumps", p.workouts[2].workoutName)
                XCTAssertEqual("Lunges", p.workouts[3].workoutName)
                XCTAssertEqual("Lunge jumps", p.workouts[4].workoutName)
                XCTAssertEqual("Marklyft", p.workouts[5].workoutName)
                XCTAssertEqual("Stallion Burpees", p.workouts[6].workoutName)
            default:
                debugPrintln("should not happen yet.")
            }
        }
    }

    func testUpperBodyPrebens() {
        ws.loadDataIfNeeded()
        let prebensWorkout = ws.fetchWorkoutProtocol("UpperBodyPrebens") as! PrebensWorkoutProtocol
        //XCTAssertEqual(WorkoutType.Prebens.rawValue, prebensWorkout.type());
        XCTAssertEqual(7, prebensWorkout.workouts().count);
        XCTAssertEqual("Bicep curl", prebensWorkout.workouts()[0].workoutName())
        XCTAssertEqual("Front bench press", prebensWorkout.workouts()[1].workoutName())
        XCTAssertEqual("Military press", prebensWorkout.workouts()[2].workoutName())
        XCTAssertEqual("Snatch", prebensWorkout.workouts()[3].workoutName())
        XCTAssertEqual("Hakdrag", prebensWorkout.workouts()[4].workoutName())
        XCTAssertEqual("Standing rowing", prebensWorkout.workouts()[5].workoutName())
        XCTAssertEqual("Squats", prebensWorkout.workouts()[6].workoutName())
    }

    func testLowerBodyPrebens() {
        ws.loadDataIfNeeded()
        let prebensWorkout = ws.fetchWorkoutProtocol("LowerBodyPrebens") as! PrebensWorkoutProtocol
        //XCTAssertEqual(WorkoutType.Prebens.rawValue, prebensWorkout.type);
        XCTAssertEqual(7, prebensWorkout.workouts().count);
        XCTAssertEqual("Russians", prebensWorkout.workouts()[0].workoutName())
        XCTAssertEqual("Squats", prebensWorkout.workouts()[1].workoutName())
        XCTAssertEqual("Flat foot jumps", prebensWorkout.workouts()[2].workoutName())
        XCTAssertEqual("Lunges", prebensWorkout.workouts()[3].workoutName())
        XCTAssertEqual("Lunge jumps", prebensWorkout.workouts()[4].workoutName())
        XCTAssertEqual("Marklyft", prebensWorkout.workouts()[5].workoutName())
        XCTAssertEqual("Stallion Burpees", prebensWorkout.workouts()[6].workoutName())
    }

    func testOrderOfPrebens() {
        let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["FHS"])
        var workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"])))
        let userService = workoutService.getUserService()
        workoutService.loadDataIfNeeded()

        let workout = workoutService.fetchWorkoutProtocol("Burpees")!
        let id = NSUUID().UUIDString
        let userWorkout = userService.newUserWorkout(id).category(WorkoutCategory.UpperBody).addWorkout(workout).save()
        var w = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: nil, weights: true, dryGround: true)
        while w?.name != "UpperBodyPrebens" {
            w = workoutService.fetchWorkout(WorkoutCategory.UpperBody.rawValue, currentUserWorkout: userWorkout, lastUserWorkout: nil, weights: true, dryGround: true)
        }

        let prebensWorkout = w as! PrebensWorkoutManagedObject
        XCTAssertEqual(WorkoutType.Prebens.rawValue, prebensWorkout.type);
        XCTAssertEqual(7, prebensWorkout.workouts.count);
        XCTAssertEqual("Bicep curl", prebensWorkout.workouts[0].workoutName)
        XCTAssertEqual("Front bench press", prebensWorkout.workouts[1].workoutName)
        XCTAssertEqual("Military press", prebensWorkout.workouts[2].workoutName)
        XCTAssertEqual("Snatch", prebensWorkout.workouts[3].workoutName)
        XCTAssertEqual("Hakdrag", prebensWorkout.workouts[4].workoutName)
        XCTAssertEqual("Standing rowing", prebensWorkout.workouts[5].workoutName)
        XCTAssertEqual("Squats", prebensWorkout.workouts[6].workoutName)
    }

    func testNewUserworkoutNoExistingWorkout() {
        ws.loadDataIfNeeded()
        let settings = Settings.settings()
        let userWorkout = ws.newUserWorkout(nil, settings: settings)!
        XCTAssertNotNil(userWorkout)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category);
        XCTAssertEqual(1, userWorkout.workouts.count);
    }

    func testNewUserworkoutNoWarmups() {
        ws.loadDataIfNeeded()
        let settings = Settings(weights: true, dryGround: true, warmup: false, duration: 2700, ignoredCategories: [WorkoutCategory.Warmup], stores: ["FHS"])
        let userWorkout = ws.newUserWorkout(nil, settings: settings)!
        XCTAssertNotNil(userWorkout)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, userWorkout.category);
        XCTAssertEqual(1, userWorkout.workouts.count);
    }

    func testNewUserworkout() {
        ws.loadDataIfNeeded()
        let settings = Settings(weights: true, dryGround: true, warmup: false, duration: 2700, ignoredCategories: [], stores: ["FHS"])
        let lastWorkout = ws.newUserWorkout(nil, settings: settings)!
        let userWorkout = ws.newUserWorkout(lastWorkout, settings: settings)!
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, userWorkout.category);
        XCTAssertNotEqual(lastWorkout.workouts[0].name, userWorkout.workouts[0].name)
    }

    func testIntervalWorkout() {
        ws.loadDataIfNeeded()
        let intervalWorkout = ws.fetchWorkoutProtocol("WormInterval") as! IntervalWorkoutProtocol
        //XCTAssertEqual(WorkoutType.Interval.rawValue, intervalWorkout.type);
        XCTAssertEqual("The Worm", intervalWorkout.work().workoutName())
        XCTAssertEqual("Mountain climber", intervalWorkout.rest().workoutName())
    }

    func testFetchRepsWorkoutDestinct() {
        ws.loadDataIfNeeded()
        let repsWorkouts = ws.fetchRepsWorkoutsDestinct()
        XCTAssertNotNil(repsWorkouts)
    }

    func testUseTestStore() {
        let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["Testing"])
        let ws = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"])))
        ws.reps(10).name("testWorkout").description("testing...").categories(WorkoutCategory.UpperBody).postRestTime(60).saveRepsWorkout()
        let workout = ws.fetchWorkoutProtocol("testWorkout")!
        XCTAssertEqual("testWorkout", workout.name())
    }

    func testCreateTestStore() {
        let jsonURL = NSBundle.mainBundle().URLForResource("test-workouts", withExtension: "json")
        let coreDataStack: CoreDataStack = CoreDataStack(modelName: "FHS", storeNames: ["Testing"])
        let ws = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"])))
        ws.importData(jsonURL!)
    }
}

