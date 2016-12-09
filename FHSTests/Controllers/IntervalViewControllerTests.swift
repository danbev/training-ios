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
    let coreDataStack: CoreDataStack = TestCoreDataStack.storesFromBundle(["FHS"], modelName: "FHS")
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
        controller = storyboard.instantiateViewController(withIdentifier: "IntervalViewController") as! IntervalViewController
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack.storesFromBundle(["User"], modelName: "User")))
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRestTimer() {
        let workout = workoutService.fetchWorkoutProtocol("WormInterval")!
        let expectation = self.expectation(description: "Testing rest timer...")
        let restTimer = CountDownTimer(callback: { (t) -> () in
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: restTimer) { controller, duration in }
        controller.viewDidLoad()

        waitForExpectations(timeout: 3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
    }

    func testWorkTimer() {
        let workout = workoutService.fetchWorkoutProtocol("WormInterval")!
        let expectation = self.expectation(description: "Testing work timer...")
        let restTimer = CountDownTimer(callback: { (t) -> () in
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: restTimer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectations(timeout: 3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
        controller.startWorkTimer(workout)
    }

}
