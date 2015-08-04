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

class DurationViewControllerTests: XCTestCase {

    var controller: DurationViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack(modelName: "FHS", storeNames: ["FHS"])
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateViewControllerWithIdentifier("DurationViewController") as! DurationViewController
        workoutService = WorkoutService(context: coreDataStack.context, userService: UserService(coreDataStack: TestCoreDataStack(modelName: "User", storeNames: ["User"])))
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWithRestTimer() {
        let workout = workoutService.fetchWorkout("Getups")!
        let expectation = expectationWithDescription("Testing timer2...")
        let timer = CountDownTimer(callback: { (dt) -> () in
            debugPrintln("in duration test CountDownTimer closure")
            expectation.fulfill()
            dt.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: timer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
    }

}