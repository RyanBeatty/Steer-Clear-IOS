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
    
    /*
        testRegisterFailureBadStatusCode
        --------------------------------
        Tests that registering fails, if the response status code is not 200
    */
    func testRegisterFailureBadStatusCode() {
        // simulate if the username already exists
        self._performRegisterTest(409, responseSuccess: false, responseMessage: "The username or phone you specified already exists")
        
        // simulate if user entered register credentials incorrectly
        self._performRegisterTest(
            400,
            responseSuccess: false,
            responseMessage: "The username, password, or phone number were entered incorrectly"
        )
        
        // simulate some random internal server error
        self._performRegisterTest(500, responseSuccess: false, responseMessage: "There was an error while registering")
    }
    
    /*
        testRegisterSuccess
        -------------------
        Tests that we can successsfully register a user into the system
    */
    func testRegisterSuccess() {
        self._performRegisterTest(200, responseSuccess: true, responseMessage: "Registered!")
    }
    
    /*
        _performRegisterTest
        --------------------
        Perform a test of the register function
    
        :responseStatusCode:    the status code the test request should return
        :responseSuccess:       the success flag the test request should return
        :responseMessage:       the message string the test request should return
    */
    func _performRegisterTest(responseStatusCode: Int32, responseSuccess: Bool, responseMessage: String) {
        // stub out network request to server register route
        OHHTTPStubs.stubRequestsPassingTest({
            request in
            return request.URL!.host == "127.0.0.1"
            }, withStubResponse: {
                _ in
                let stubData = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode: responseStatusCode, headers: nil)
        })
        
        // create expectation for testing
        let expectation = self.expectationWithDescription("response of post request arrived")
        
        // make request
        SCNetwork.register(
            "foo",
            password: "bar",
            phone: "baz",
            completionHandler: {
                success, message in
                
                // assert that register succeeded
                XCTAssertEqual(success, responseSuccess)
                XCTAssertEqual(message, responseMessage)
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

}
