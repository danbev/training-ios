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
    let coreDataStack: CoreDataStack = TestCoreDataStack.storesFromBundle(["FHS"], modelName: "FHS")
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateViewControllerWithIdentifier("DurationViewController") as! DurationViewController
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack.storesFromBundle(["User"], modelName: "User")))
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWithRestTimer() {
        let workout = workoutService.fetchWorkoutProtocol("Getups")!
        let expectation = expectationWithDescription("Testing timer2...")
        let timer = CountDownTimer(callback: { (dt) -> () in
            debugPrint("in duration test CountDownTimer closure")
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