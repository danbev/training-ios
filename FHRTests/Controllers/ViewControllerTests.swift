//
//  FHRTests.swift
//  FHRTests
//
//  Created by Daniel Bevenius on 14/09/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import XCTest
import FHS

class ViewControllerTests: XCTestCase {
    
    var controller: ViewController!
    var storyboard: UIStoryboard!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        storyboard = UIApplication.sharedApplication().keyWindow!.rootViewController?.storyboard
        controller = storyboard.instantiateViewControllerWithIdentifier("ViewController") as? ViewController

        coreDataStack = TestCoreDataStack()
    }
    
    func testExample() {
        //println(controller.tasks)
        //XCTAssertEqual(0, controller.tasks.count)
    }
    
}
