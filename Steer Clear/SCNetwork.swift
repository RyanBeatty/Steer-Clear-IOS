//
//  SCNetwork.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import SwiftyJSON

// hostname of server
let HOSTNAME = "http://127.0.0.1:5000"

// api url routes
let REGISTER_ROUTE = "/register"
let LOGIN_ROUTE = "/login"
let LOGOUT_ROUTE = "/logout"
let RIDE_REQUEST_ROUTE = "/api/rides"
let CLEAR_ROUTE = "/clear"
let DELETE_ROUTE = "/api/rides/"

// complete api route strings
let REGISTER_URL_STRING = HOSTNAME + REGISTER_ROUTE
let LOGIN_URL_STRING = HOSTNAME + LOGIN_ROUTE
let LOGOUT_URL_STRING = HOSTNAME + LOGOUT_ROUTE
let RIDE_REQUEST_URL_STRING = HOSTNAME + RIDE_REQUEST_ROUTE
let ClEAR_URL_STRING = HOSTNAME + CLEAR_ROUTE
let DELETE_URL_STRING = HOSTNAME + DELETE_ROUTE

var currentRideData = Dictionary<String, Any>()

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
        // create login url
        let loginUrl = NSURL(string: LOGIN_URL_STRING)
        
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
    
    class func requestRide(startLat: String, startLong: String, endLat: String, endLong: String, numPassengers: String, completionHandler: (success: Bool, needLogin: Bool, message: String, ride: Ride?)->()) {
        
        // create rideRequest url
        let rideRequestUrl = NSURL(string: RIDE_REQUEST_URL_STRING)
        
        // build form data string
        let formDataString = "start_latitude=\(startLat)" +
                             "start_longitude=\(startLong)" +
                             "end_latitude=\(endLat)" +
                             "end_longitude=\(endLong)" +
                             "num_passengers=\(numPassengers)"
        
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
                if(id == nil || numPassengers == nil || pickupAddress == nil || dropoffAddress == nil || pickupTime == nil) {
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
                completionHandler(success: false, needLogin: false, message: "There was an error while requesting a ride", ride: nil)
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
        add
        ---
        Attempts to add ride to queue
        
        :start_lat:             Pickup latitude
        :start_long:            Pickup Longitude
        :end_lat:               Dropoff latitude
        :end_long:              Dropoff Longitude
        :numOfPassengers:       Number of Passengers
    */
    class func add(start_lat: String, start_long: String, end_lat: String, end_long: String, numOfPassengers :String,
        completionHandler: (success: Bool, message: String) -> ()) {
            
        let postData = NSMutableData(data: "num_passengers=\(numOfPassengers)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_latitude=\(start_lat)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_longitude=\(start_long)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_latitude=\(end_lat)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_longitude=\(end_long)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: RIDE_REQUEST_URL_STRING)!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            
//            update with real completionHandler, neeed to declare it in the func declation 
            case 201:
                completionHandler(success: true, message: "Added Ride")
                
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
                    // The JSONObjectWithData constructor didn't return an error.
                    
                    
                    var dropoff_address: AnyObject = (response["ride"]!["dropoff_address"]!)!
                    var dropoff_time: AnyObject = (response["ride"]!["dropoff_time"]!)!
                    var end_latitude: AnyObject = (response["ride"]!["end_latitude"]!)!
                    var end_longitude: AnyObject = (response["ride"]!["end_longitude"]!)!
                    var id: AnyObject = (response["ride"]!["id"]!)!
                    var pickup_address: AnyObject = (response["ride"]!["pickup_address"]!)!
                    var pickup_time: AnyObject = (response["ride"]!["pickup_time"]!)!
                    var start_latitude: AnyObject = (response["ride"]!["start_latitude"]!)!
                    var start_longitude: AnyObject = (response["ride"]!["start_longitude"]!)!
                    var travel_time: AnyObject = (response["ride"]!["travel_time"]!)!
                    
                    currentRideData = [ "dropoff_address" : "\(dropoff_address)",
                        "dropoff_time" : "\(dropoff_time)",
                        "end_latitude" : end_latitude,
                        "end_longitude" : end_longitude,
                        "id" : id,
                        "pickup_address" : "\(pickup_address)",
                        "pickup_time" : "\(pickup_time)",
                        "start_latitude" : start_latitude,
                        "start_longitude" : start_longitude,
                        "travel_time" : travel_time,
                    ]
                    
                }
            case 401:
                completionHandler(success: false, message: "Not logged in")
            default:
                completionHandler(success: false, message: "There was an error while posting ")
            }
        })
        
        task.resume()
    }
    
    /*
    getRideData
    -----------
    Returns all ride data
    
    */
    
    class func getRideData() -> Dictionary<String, Any> {
        return currentRideData
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
                completionHandler(success: false, message: "There was an error while canceling your ride request")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
        logout
        ------
        Logs user out
    */
    class func logout(){
        let request = NSMutableURLRequest(URL: NSURL(string: LOGOUT_URL_STRING)!,
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
