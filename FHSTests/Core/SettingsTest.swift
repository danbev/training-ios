//
//  SettingsTest.swift
//  FHS
//
//  Created by Daniel Bevenius on 04/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import XCTest
import FHS
import Foundation

class SettingsTest: XCTestCase {

    func testUpperBodyType() {
        let settings = Settings.settings()
        XCTAssertEqual(1, settings.stores.count)
        XCTAssertEqual("FHS", settings.stores[0])
    }

    func testSearchForSqliteStores() {
        let stores: [String] = Settings.findAllStores()
        println(stores)
        XCTAssertEqual("FHS.sqlite", stores[0])
    }

}
