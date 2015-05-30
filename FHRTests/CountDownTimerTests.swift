//
//  NSTimerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 13/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import FHR
import XCTest

class CountDownTimerTests: XCTestCase {

    func testTimer() {
        let expectation = expectationWithDescription("Timer should fire once every second")
        let timer = CountDownTimer(callback: { (timer) -> () in
            println(timer.elapsedTime())
            expectation.fulfill()
            }, countDown: 6)
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertFalse(timer.isDone())
        }
    }

    func callback() {
        println("callback...")
    }
    
}

