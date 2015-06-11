//
//  DurationViewControllerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 21/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import FHR
import XCTest

class IntervalViewControllerTests: XCTestCase {

    var controller: IntervalViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack()
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

    func testWorkRestTimer() {
        let workout = workoutService.fetchWorkout("WormInterval")!
        let expectation = expectationWithDescription("Testing timer...")
        let timer = CountDownTimer(callback: { (t) -> () in
            debugPrintln("in interval test CountDownTimer closure")
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, restTimer: timer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
        XCTAssertFalse(self.controller.isTimeLabelVisible())
        XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
    }

}
