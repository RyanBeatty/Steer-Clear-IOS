//
//  SCNetwork.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

// hostname of server
let HOSTNAME = "https://steerclear.wm.edu/"

// api url routes
let REGISTER_ROUTE = "/register"
let LOGIN_ROUTE = "/login"
let LOGOUT_ROUTE = "/logout"
let RIDE_REQUEST_ROUTE = "/api/rides"
let CLEAR_ROUTE = "/clear"
let DELETE_ROUTE = "/api/rides/"
let INDEX = "/index"

// complete api route strings
let REGISTER_URL_STRING = HOSTNAME + REGISTER_ROUTE
let LOGIN_URL_STRING = HOSTNAME + LOGIN_ROUTE
let LOGOUT_URL_STRING = HOSTNAME + LOGOUT_ROUTE
let RIDE_REQUEST_URL_STRING = HOSTNAME + RIDE_REQUEST_ROUTE
let ClEAR_URL_STRING = HOSTNAME + CLEAR_ROUTE
let DELETE_URL_STRING = HOSTNAME + DELETE_ROUTE

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
        let registerUrl = NSURL(string: REGISTER_URL_STRING)
        
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
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while registering")
            }
        })
        
        // start task
        task.resume()
    }
    
    
    /*
    checkIndex
    ----------
    Checks to see whether user is logged in by checking the index page, if user is logged in, page will
    return a 200 status code. If not, it will return a 401.
    
    */
    class func checkIndex(completionHandler: (success: Bool, message: String) -> ()) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // create register url
        let indexUrl = NSURL(string: "http://steerclear.wm.edu/api/rides/15")
        
        // initialize url request object
        var request = NSMutableURLRequest(URL: indexUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "GET"
        
        let data: NSData? = defaults.objectForKey("cookie") as? NSData
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObjectWithData(cookie) as? NSArray
            if let cookies = datas {
                for c in cookies as! [NSHTTPCookie] {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(c)
                }
            }
        }

        // initialize session object create http request task
        var session = NSURLSession.sharedSession()
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil) {
                completionHandler(success: false, message: "Error checking if user is logged in")

                return
            }
            
            // if there is no response, request failed
            if(response == nil) {
                completionHandler(success: false, message: "There was an error while checking whether user is logged in.")
                
                return
            }
            
            // else check the request status code to see if registering succeeded
            let httpResponse = response as! NSHTTPURLResponse
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            switch(httpResponse.statusCode) {
            case 200:
                println("loggedin")
                completionHandler(success: true, message: "Logged In")
            case 401:
                println("User not logged in: Status code 401")
                completionHandler(success: false, message: "User not loggefd in: Status code 401")
            default:
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while checking if logged in")
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
        // create login url
        let loginUrl = NSURL(string: LOGIN_URL_STRING)
        let defaults = NSUserDefaults.standardUserDefaults()
        
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
                    
                    let cookieJar: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                    let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(cookieJar)
                    defaults.setObject(data, forKey: "cookie")
                    
                
                completionHandler(success: true, message: "Logged in!")
            case 400:
                completionHandler(success: false, message: "Invalid username or password")
            default:
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while logging in")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
    requestRide
    -----------
    Attempts to make a new ride request
    
    :startLat:          starting latitude coordinate
    :startLong:         starting longitude coordinate
    :endLat:            ending latitude coordinate
    :endLong:           ending longitude coordinate
    :numPassengers:     number of passengers in the ride request
    :completionHandler: callback
    */
    class func requestRide(startLat: String, startLong: String, endLat: String, endLong: String, numPassengers: String, completionHandler: (success: Bool, needLogin: Bool, message: String, ride: Ride?)->()) {
        
        // create rideRequest url
        let rideRequestUrl = NSURL(string: RIDE_REQUEST_URL_STRING)
        
        // build form data string
        let formDataString = "start_latitude=\(startLat)" +
            "&start_longitude=\(startLong)" +
            "&end_latitude=\(endLat)" +
            "&end_longitude=\(endLong)" +
        "&num_passengers=\(numPassengers)"
        
        // initialize url request object
        var request = NSMutableURLRequest(URL: rideRequestUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data: formDataString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // initialize session object create http request task
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil || response == nil || data == nil) {
                completionHandler(success: false, needLogin: false, message: "There was a network error while requesting a ride", ride:nil)
                return
            }
            
            // else check the request status code to see if login succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 201:
                // get json object
                let json = JSON(data: data)
                
                // get ride request data
                let id = json["ride"]["id"].int
                let numPassengers = json["ride"]["num_passengers"].int
                let pickupAddress = json["ride"]["pickup_address"].string
                let dropoffAddress = json["ride"]["dropoff_address"].string
                let pickupTime = json["ride"]["pickup_time"].string
                
                // check for error in json response
                if id == nil || numPassengers == nil || pickupAddress == nil || dropoffAddress == nil || pickupTime == nil {
                    completionHandler(success:false, needLogin:true, message: "There was an error while requesting a ride", ride: nil)
                }
                
                // create ride object
                let ride = Ride(id: id!, numPassengers: numPassengers!, pickupAddress: pickupAddress!, dropoffAddress: dropoffAddress!, pickupTime: pickupTime!)
                
                completionHandler(success: true, needLogin: false, message: "Ride requested!", ride: ride)
            case 400:
                completionHandler(success: false, needLogin: false, message: "You've entered some ride information incorrectly", ride: nil)
            case 401:
                completionHandler(success: false, needLogin: true, message: "Please Login", ride: nil)
            default:
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, needLogin: false, message: "There was an error while requesting a ride", ride: nil)
            }
        })
        
        // start task
        task.resume()
    }
    
    
    /*
    deleteRideWithId
    --------------
    Attempts to delete current ride request
    
    :rideId:                Current Ride Id
    :completionHandler:     Callback function called when response is gotten.
    Function that takes a boolean
    
    */
    class func deleteRideWithId(rideId: String, completionHandler: (success: Bool, message: String) -> ()) {
        
        // create delete url
        var deleteUrl = NSURL(string: DELETE_URL_STRING + "\(rideId)")
        
        // initialize url request object
        var request = NSMutableURLRequest(URL: deleteUrl!)
        
        // set http method to DELETE
        request.HTTPMethod = "DELETE"
        
        // initialize session object create http request task
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil || response == nil) {
                completionHandler(success: false, message: "There was a network error while canceling your ride request")
                return
            }
            
            // else check the request status code to see if registering succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 204:
                completionHandler(success: true, message: "Canceled your ride request!")
            case 404:
                completionHandler(success: false, message: "You have no current ride requests")
            default:
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while canceling your ride request")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
    logout
    ------
    Attempts to log the user out
    
    :completionHandler: callback method that takes a success flag and a string message
    */
    class func logout(completionHandler: (success: Bool, message: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: LOGOUT_URL_STRING)!)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            // if there was an error, request failed
            if(error != nil || response == nil || data == nil) {
                completionHandler(success: false, message: "There was a network error while logging out")
                return
            }
            
            // else check the request status code to see if logging out succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                completionHandler(success: true, message: "Logged out!")
            default:
                println("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while logging out")
            }
        })
        
        dataTask.resume()
    }
}
