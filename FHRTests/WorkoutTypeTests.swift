//
//  WorkoutTypeTests.swift
//  FHR
//
//  Created by Daniel Bevenius on 15/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//
import Foundation
import UIKit
import XCTest
import FHR

class WorkoutTypeTests: XCTestCase {

    func testUpperBodyType() {
        XCTAssertEqual("upperbody", Category.UpperBody.rawValue)
        XCTAssertEqual(Category.UpperBody, Category(rawValue: "upperbody")!)
    }

    func testLowerBodyType() {
        XCTAssertEqual("lowerbody", Category.LowerBody.rawValue)
        XCTAssertEqual(Category.LowerBody, Category(rawValue: "lowerbody")!)
    }

    func testCardioType() {
        XCTAssertEqual("cardio", Category.Cardio.rawValue)
        XCTAssertEqual(Category.Cardio, Category(rawValue: "cardio")!)
    }
    
}
