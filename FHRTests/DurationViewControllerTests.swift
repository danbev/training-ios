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

class DurationViewControllerTests: XCTestCase {

    var controller: DurationViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack()
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateViewControllerWithIdentifier("DurationViewController") as! DurationViewController
        controller.loadView()
        workoutService = WorkoutService(context: coreDataStack.context)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testUI() {
        workoutService.loadDataIfNeeded()
        let workout = workoutService.fetchWorkout("Getups") as! DurationWorkout
        controller.workout = workout
        let expectation = expectationWithDescription("Testing timer...")
        let timer = Timer(callback: {(timer) -> () in
            println("rest timer triggered....")
            expectation.fulfill()
        }, countDown: 60)
        controller.restTimer(timer)
        controller.viewDidLoad()
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.timeLabel.hidden.boolValue)
        }
    }

}