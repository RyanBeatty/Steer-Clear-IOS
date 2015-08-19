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

/*
    SCNetworkBaseTestCase
    ---------------------
    Base test class for network tests
*/
class SCNetworkBaseTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    /*
    _stub
    -----
    Stubs out a network request with the passed in status code
    
    :responseStatusCode:    The status code the response should return
    */
    func _stub(responseStatusCode: Int32) -> OHHTTPStubsDescriptor {
        // stub out network request to server register route
        var stub = OHHTTPStubs.stubRequestsPassingTest({
            request in
            return request.URL!.host == "127.0.0.1"
            }, withStubResponse: {
                _ in
                let stubData = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode: responseStatusCode, headers: nil)
        })
        
        return stub
    }
    
    func _stubBadNetwork() {
        // stub out the entire network
        OHHTTPStubs.stubRequestsPassingTest({
            request in
            return request.URL!.host == "127.0.0.1"
            }, withStubResponse: {
                _ in
                
                // NOTE: -1009 actually stands for the constant kCFURLErrorNotConnectedToInternet in CFNetwork
                // but I couldn't get swift to recognize the name, so I just used the value
                let notConnectedError = NSError(domain:NSURLErrorDomain, code:-1009, userInfo:nil)
                return OHHTTPStubsResponse(error:notConnectedError)
        })
    }
}

/*
    RegisterTestCase
    ----------------
    Tests the SCNetwork.register function
*/
class RegisterTestCase: SCNetworkBaseTestCase {
    
    /*
        testRegisterFailureBadNetwork
        -----------------------------
        Tests that the register function can handle the network being down
    */
    func testRegisterFailureBadNetwork() {
        self._stubBadNetwork()
        self._performRegisterTest(false, responseMessage: "There was a network error while registering")
    }
    
    /*
        testRegisterFailureBadStatusCode
        --------------------------------
        Tests that registering fails, if the response status code is not 200
    */
    func testRegisterFailureBadStatusCode() {
        // simulate if the username already exists
        self._stub(409)
        self._performRegisterTest(false, responseMessage: "The username or phone you specified already exists")
        
        // simulate if user entered register credentials incorrectly
        self._stub(400)
        self._performRegisterTest(
            false,
            responseMessage: "The username, password, or phone number were entered incorrectly"
        )
        
        // simulate some random internal server error
        self._stub(500)
        self._performRegisterTest(false, responseMessage: "There was an error while registering")
    }
    
    /*
        testRegisterSuccess
        -------------------
        Tests that we can successsfully register a user into the system
    */
    func testRegisterSuccess() {
        self._stub(200)
        self._performRegisterTest(true, responseMessage: "Registered!")
    }
    
    /*
        _performRegisterTest
        --------------------
        Perform a test of the register function
    
        :responseSuccess:       the success flag the test request should return
        :responseMessage:       the message string the test request should return
    */
    func _performRegisterTest(responseSuccess: Bool, responseMessage: String) {
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


/*
    LoginTestCase
    -------------
    Tests for the SCNetwork.login function
*/
class LoginTestCase: SCNetworkBaseTestCase {
    
    /*
        testLoginFailureBadNetwork
        --------------------------
        Tests that the login function handles the network being down
    */
    func testLoginFailureBadNetwork() {
        self._stubBadNetwork()
        self._performLoginTest(
            "foo",
            password: "bar",
            responseSuccess: false,
            responseMessage: "There was a network error while logging in"
        )
    }
    
    /*
        testLoginFailureBadStatusCode
        -----------------------------
        Tests that login function handles bad status codes correctly
    */
    func testLoginFailureBadStatusCode() {
        // simulate if the user does not exist
        self._stub(400)
        self._performLoginTest(
            "foo",
            password: "bar",
            responseSuccess: false,
            responseMessage: "Invalid username or password"
        )
        
        // simulate if there is an internal server error
        self._stub(500)
        self._performLoginTest(
            "foo",
            password: "bar",
            responseSuccess: false,
            responseMessage: "There was an error while logging in"
        )
    }
    
    /*
        testLoginSuccess
        ----------------
        Tests that a user can successfully login
    */
    func testLoginSuccess() {
        
        self._stub(200)
        self._performLoginTest(
            "foo",
            password: "bar",
            responseSuccess: true,
            responseMessage: "Logged in!"
        )
    }
    
    /*
    _performLoginTest
    --------------------
    Perform a test of the login function
    
    :responseSuccess:       the success flag the test request should return
    :responseMessage:       the message string the test request should return
    */
    func _performLoginTest(username: String, password: String, responseSuccess: Bool, responseMessage: String) {
        // create expectation for testing
        let expectation = self.expectationWithDescription("response of post request arrived")
        
        // make request
        SCNetwork.login(
            username,
            password: password,
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







