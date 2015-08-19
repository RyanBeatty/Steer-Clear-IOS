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
            "username=\(username)&password=\(password)&phone=%2B1\(phone)".dataUsingEncoding(NSUTF8StringEncoding)!)
    
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
    
    class func add(start_lat: String, start_long: String, end_lat: String, end_long: String, numOfPassengers :String) {
        let postData = NSMutableData(data: "num_passengers=\(numOfPassengers)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_latitude=\(start_lat)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_longitude=\(start_long)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_latitude=\(end_lat)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_longitude=\(end_long)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/api/rides")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var response = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var id: AnyObject = (response["ride"]!["id"]!)!
                    var pickup: AnyObject = (response["ride"]!["pickup_time"]!)!
                    println("Ride ID : \(id)")
                    println("Pick Up Time : \(pickup)")
                    
            }
        })
        
        task.resume()
    }
    
    class func clear(){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/api/clear")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    class func logout(){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/logout")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    
    
}
