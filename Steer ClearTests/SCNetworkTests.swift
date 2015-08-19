//
//  SCNetworkTests.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import XCTest

class SCNetworkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterSuccess() {
        var username = "rvbeatty"
        var password = "HighMnt2"
        var phone = "13018021296"
        
        let expectation = self.expectationWithDescription("response of post request arrived")
        
        SCNetwork.register(
            username,
            password: password,
            phone: phone,
            completionHandler: {
                success, statusCode in
                XCTAssertTrue(success, "HTTP POST /register should succeed")
                XCTAssertEqual(statusCode, 200, "HTTP POST /register success response should be 302")
                expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            error in
            if (error != nil) {
                print("Error: \(error.localizedDescription)")
            }
        })
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
