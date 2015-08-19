//
//  SCNetwork.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit

let HOSTNAME = "http://127.0.0.1:5000"

let REGISTER_ROUTE = "/register"
let LOGIN_ROUTE = "/login"

let REGISTER_URL_STRING = HOSTNAME + REGISTER_ROUTE
let LOGIN_URL_STRING = HOSTNAME + LOGIN_ROUTE

class SCNetwork: NSObject {
    
    /*
        register
        --------
        Attempts to register a new user into the system
    
        :username:              W&M username string
        :password:              W&M password string
        :phone:                 User phone number (e.x. 1xxxyyyzzzz) NOTE: there is no plus sign
        :completionHandler:     Callback function called when response is gotten. Function that takes a boolean stating
                                whether the register request succeeded or not. If the request failed, the :message: parameter
                                will contain an error message
    */
    class func register(username: String, password: String, phone: String, completionHandler: (success: Bool, message: String) -> ()) {
        
        // create register url
        var registerUrl = NSURL(string: REGISTER_URL_STRING)
        
        // initialize url request object
        var request = NSMutableURLRequest(URL: registerUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data:
            "username=\(username)&password=\(password)&phone=%2B\(phone)".dataUsingEncoding(NSUTF8StringEncoding)!)
    
        // initialize session object create http request task
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in

            // if there was an error, request failed
            if(error != nil) {
                completionHandler(success: false, message: "There was a network error while registering")
                return
            }
            
            // if there is no response, request failed
            if(response == nil) {
                completionHandler(success: false, message: "There was an error while registering")
                return
            }
            
            // else check the request status code to see if registering succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                completionHandler(success: true, message: "Registered!")
            case 409:
                completionHandler(success: false, message: "The username or phone you specified already exists")
            case 400:
                completionHandler(success: false, message: "The username, password, or phone number were entered incorrectly")
            default:
                completionHandler(success: false, message: "There was an error while registering")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
        login
        -----
        Attempts to log the user in
    
        :username:          the username string of the user attempting to login
        :password:          the password string of the user attempting to login
        :completionHandler: the function to call when the response is recieved. Takes a
                            boolean flag signifying if the request succeeded and a message string
    */
    class func login(username: String, password: String, completionHandler: (success: Bool, message: String) -> ()) {
        // create register url
        var loginUrl = NSURL(string: LOGIN_URL_STRING)
        
        // initialize url request object
        var request = NSMutableURLRequest(URL: loginUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data:
            "username=\(username)&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // initialize session object create http request task
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil) {
                completionHandler(success: false, message: "There was a network error while logging in")
                return
            }
            
            // if there is no response, request failed
            if(response == nil) {
                completionHandler(success: false, message: "There was an error while logging in")
                return
            }
            
            // else check the request status code to see if login succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                completionHandler(success: true, message: "Logged in!")
            case 400:
                completionHandler(success: false, message: "Invalid username or password")
            default:
                completionHandler(success: false, message: "There was an error while logging in")
            }
        })
        
        // start task
        task.resume()
    }
    
    
    
}
