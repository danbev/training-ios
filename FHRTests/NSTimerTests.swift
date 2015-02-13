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

class NSTimerTests: XCTestCase {

    func testNSTimer() {
        let expectation = expectationWithDescription("Timer should fire once every second")
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("callback"), userInfo: nil, repeats: true)
        expectation.fulfill()
        waitForExpectationsWithTimeout(3.0, handler:nil)
    }

    func callback() {
        println("callback...")
    }
    
}

