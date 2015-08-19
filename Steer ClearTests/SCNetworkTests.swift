//
//  SCNetworkTests.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs

class SCNetworkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterFailedUserAlreadyExists() {
        
    }
    
    /*
        testRegisterSuccess
        -------------------
        Tests that we can successsfully register a user into the system
    */
    func testRegisterSuccess() {
        
        // stub out network request to server register route
        OHHTTPStubs.stubRequestsPassingTest({
            request in
            return request.URL!.host == "127.0.0.1"
        }, withStubResponse: {
            _ in
            let stubData = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        })
        
        // fake login credentials
        var username = "foo"
        var password = "bar"
        var phone = "baz"
        
        // create expectation for testing
        let expectation = self.expectationWithDescription("response of post request arrived")
        
        // make request
        SCNetwork.register(
            username,
            password: password,
            phone: phone,
            completionHandler: {
                success, message in
                
                // assert that register succeeded
                XCTAssertTrue(success, "HTTP POST /register should succeed")
                XCTAssertEqual(message, "Registered!")
                expectation.fulfill()
        })
        
        // wait for response to finish
        waitForExpectationsWithTimeout(10, handler: {
            error in
            if (error != nil) {
                print("Error: \(error.localizedDescription)")
            }
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
