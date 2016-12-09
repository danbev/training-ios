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
        let expectation = self.expectation(description: "CountDownTimer should fire once every second")
        let timer = CountDownTimer(callback: { (t) -> () in expectation.fulfill() }, countDown: 6)
        waitForExpectations(timeout: 3) { (error) in
            XCTAssertFalse(timer.isDone())
            timer.stop()
        }
    }

}

