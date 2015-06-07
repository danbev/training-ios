//
//  PrebensViewControllerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 03/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import FHR
import XCTest

class PrebensViewControllerTests: XCTestCase {

    var controller: PrebensViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack()
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateViewControllerWithIdentifier("PrebensViewController") as! PrebensViewController
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWithRestTimer() {
        let workout = workoutService.fetchWorkout("UpperBodyPrebens")!
        let expectation = expectationWithDescription("Testing timer...")
        let timer = CountDownTimer(callback: { (t) -> () in
            debugPrintln("in Prebends test CountDownTimer closure")
            expectation.fulfill()
            }, countDown: 60)
        controller.initWith(workout, restTimer: timer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
    }
    
}
