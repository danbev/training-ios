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
import FHS

class WorkoutCategoryTests: XCTestCase {

    func testUpperBodyType() {
        XCTAssertEqual("Upperbody", WorkoutCategory.UpperBody.rawValue)
        XCTAssertEqual(WorkoutCategory.UpperBody, WorkoutCategory(rawValue: "Upperbody")!)
    }

    func testLowerBodyType() {
        XCTAssertEqual("Lowerbody", WorkoutCategory.LowerBody.rawValue)
        XCTAssertEqual(WorkoutCategory.LowerBody, WorkoutCategory(rawValue: "Lowerbody")!)
    }

    func testCardioType() {
        XCTAssertEqual("Cardio", WorkoutCategory.Cardio.rawValue)
        XCTAssertEqual(WorkoutCategory.Cardio, WorkoutCategory(rawValue: "Cardio")!)
    }

    func testNextCategoryEmpty() {
        let ignore = Set<WorkoutCategory>()
        let next = WorkoutCategory.Warmup.next(ignore)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, next.rawValue)
    }

    func testNextWarmupCategoryIgnoreUpperBody() {
        let ignore: Set = [WorkoutCategory.UpperBody]
        let next = WorkoutCategory.Warmup.next(ignore)
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, next.rawValue)
    }

    func testNextWarmupCategoryIgnoreLowerBody() {
        let ignore: Set = [WorkoutCategory.LowerBody]
        let next = WorkoutCategory.Warmup.next(ignore)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, next.rawValue)
    }

    func testNextWarmupCategoryIgnoreUpperAndLowerBody() {
        let ignore: Set = [WorkoutCategory.UpperBody, WorkoutCategory.LowerBody]
        let next = WorkoutCategory.Warmup.next(ignore)
        XCTAssertEqual(WorkoutCategory.Cardio, next)
    }

    func testNextUpperBodyCategoryIgnoreLowerBody() {
        let ignore: Set = [WorkoutCategory.LowerBody]
        let next = WorkoutCategory.UpperBody.next(ignore)
        XCTAssertEqual(WorkoutCategory.Cardio.rawValue, next.rawValue)
    }

    func testNextUpperBodyCategoryIgnoreLowerBodyAndCardio() {
        let ignore: Set = [WorkoutCategory.LowerBody, WorkoutCategory.Cardio]
        let next = WorkoutCategory.UpperBody.next(ignore)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, next.rawValue)
    }

    func testNextLowerBodyCategoryIgnoreCardio() {
        let ignore: Set = [WorkoutCategory.Cardio]
        let next = WorkoutCategory.LowerBody.next(ignore)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, next.rawValue)
    }

    func testNextLowerBodyCategoryIgnoreCardioAndUpperBody() {
        let ignore: Set = [WorkoutCategory.Cardio, WorkoutCategory.UpperBody]
        let next = WorkoutCategory.LowerBody.next(ignore)
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, next.rawValue)
    }

    func testNextCardioCategoryIgnoreUpperBody() {
        let ignore: Set = [WorkoutCategory.UpperBody]
        let next = WorkoutCategory.Cardio.next(ignore)
        XCTAssertEqual(WorkoutCategory.LowerBody.rawValue, next.rawValue)
    }

    func testNextCardioCategoryIgnoreLowerBody() {
        let ignore: Set = [WorkoutCategory.LowerBody]
        let next = WorkoutCategory.Cardio.next(ignore)
        XCTAssertEqual(WorkoutCategory.UpperBody.rawValue, next.rawValue)
    }

    func testNextCardioCategoryIgnoreUpperAndLowerBody() {
        let ignore: Set = [WorkoutCategory.UpperBody, WorkoutCategory.LowerBody]
        let next = WorkoutCategory.Cardio.next(ignore)
        XCTAssertEqual(WorkoutCategory.Cardio.rawValue, next.rawValue)
    }

}
