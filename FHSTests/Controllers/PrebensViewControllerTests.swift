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
import FHS
import XCTest

class PrebensViewControllerTests: XCTestCase {

    var controller: PrebensViewController!
    let coreDataStack: CoreDataStack = TestCoreDataStack.storesFromBundle(["FHS"], modelName: "FHS")
    var workoutService: WorkoutService!

    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
        controller = storyboard.instantiateViewController(withIdentifier: "PrebensViewController") as! PrebensViewController
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: UserService(coreDataStack: TestCoreDataStack.storesFromBundle(["User"], modelName: "User")))
        workoutService.loadDataIfNeeded()
        controller.loadView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWithRestTimer() {
        let workout = workoutService.fetchWorkoutProtocol("UpperBodyPrebens")!
        let expectation = self.expectation(description: "Testing timer...")
        let timer = CountDownTimer(callback: { (t) -> () in
            debugPrint("in Prebends test CountDownTimer closure")
            expectation.fulfill()
            t.stop()
            }, countDown: 60)
        controller.initWith(workout, userWorkouts: nil, restTimer: timer) { controller, duration in }
        controller.viewDidLoad()
        waitForExpectations(timeout: 3) { (error) in
            XCTAssertFalse(self.controller.isTimeLabelVisible())
            XCTAssertEqual("Rest time:", self.controller.timeLabelText()!)
        }
    }
    
}
