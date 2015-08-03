//
//  DurationViewControllerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 21/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import FHS
import XCTest

class IntervalViewControllerTests: XCTestCase {

    var controller: IntervalViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["FHS"])
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateViewControllerWithIdentifier("IntervalViewController") as! IntervalViewController
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRestTimer() {
        let workout = workoutService.fetchWorkout("WormInterval")!
        let expectation = expectationWithDescription("Testing rest timer...")
        let restTimer = CountDownTimer(callback: { (t) -> () in
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: restTimer) { controller, duration in }
        controller.viewDidLoad()

        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
    }

    func testWorkTimer() {
        let workout = workoutService.fetchWorkout("WormInterval")!
        let expectation = expectationWithDescription("Testing work timer...")
        let restTimer = CountDownTimer(callback: { (t) -> () in
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: restTimer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
        controller.startWorkTimer(workout)
    }

}
