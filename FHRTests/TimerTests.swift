//
//  TimerTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 30/05/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import FHR
import XCTest

class TimerTests: XCTestCase {
    
    func testTimer() {
        let exp = expectationWithDescription("TimerTest should fire once every second")
        let timer = Timer(callback: { (t) -> () in
            let time = t.elapsedTime()
            if time.sec > 2 {
                exp.fulfill()
            } else {
                XCTAssertTrue(time.min == 0)
                XCTAssertTrue(time.sec <= 2)
            }
            })
        waitForExpectationsWithTimeout(5) { (error) in
            XCTAssertFalse(timer.isDone())
            timer.stop()
        }
    }

}
