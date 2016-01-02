//
//  CoreDataStackTest.swift
//  FHS
//
//  Created by Daniel Bevenius on 07/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import FHS
import XCTest


class CoreDataStackTest: XCTestCase {

    var fileManager: NSFileManager!

    override func setUp() {
        fileManager = NSFileManager.defaultManager()
    }

    func testNewStore() {
        let url = CoreDataStack.newStore("TestNewStore", modelName: "FHS");
        XCTAssertTrue(fileManager.fileExistsAtPath(url.path!))
        removeFile(url)
        XCTAssertFalse(fileManager.fileExistsAtPath(url.path!))
    }

    func testListStoresNames() {
        let url = CoreDataStack.newStore("TestListStore", modelName: "FHS");
        let storeNames = CoreDataStack.listStoreNames()
        XCTAssertFalse(storeNames.isEmpty)
        XCTAssertTrue(storeNames.filter({ $0 == "TestListStore" }).count == 1)
        removeFile(url)
    }

    func testCopyStoreFromBundle() {
        let storeUrl = CoreDataStack.copyStoreFromBundle("FHS")
        print("storeUrl: \(storeUrl)")
        //XCTAssertTrue(storeUrl.e)
        let storeNames = CoreDataStack.listStoreNames()
        print("StoreNames: \(storeNames)")
        XCTAssertFalse(storeNames.isEmpty)
    }

    func removeFile(url: NSURL) {
        do {
            try fileManager.removeItemAtURL(url)
        } catch let error as NSError {
            print(error);
        }
    }

}