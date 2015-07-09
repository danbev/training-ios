//
//  CountDownTimerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 13/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import FHS
import XCTest

class CountDownTimerTests: XCTestCase {

    func testCountDownTimer() {
        let expectation = expectationWithDescription("CountDownTimer should fire once every second")
        var timer = CountDownTimer(callback: { (t) -> () in expectation.fulfill() }, countDown: 6)
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(timer.isDone())
            timer.stop()
        }
    }

}

