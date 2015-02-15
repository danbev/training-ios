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
        XCTAssertEqual("upperbody", Type.UpperBody.rawValue)
        XCTAssertEqual(Type.UpperBody, Type(rawValue: "upperbody")!)
    }

    func testLowerBodyType() {
        XCTAssertEqual("lowerbody", Type.LowerBody.rawValue)
        XCTAssertEqual(Type.LowerBody, Type(rawValue: "lowerbody")!)
    }

    func testCardioType() {
        XCTAssertEqual("cardio", Type.Cardio.rawValue)
        XCTAssertEqual(Type.Cardio, Type(rawValue: "cardio")!)
    }
    
}
