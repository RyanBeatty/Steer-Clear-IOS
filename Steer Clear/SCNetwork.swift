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

let REGISTER_URL_STRING = HOSTNAME + REGISTER_ROUTE

class SCNetwork: NSObject {
    
    class func register(username: String, password: String, phone: String, completionHandler: (success: Bool, statusCode: Int) -> ()) {
        
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
            println("response: \(response)")
            
            if(error != nil) {
                completionHandler(success: false, statusCode: 0)
                return
            }
            
            if(response == nil) {
                completionHandler(success: false, statusCode: 0)
                return
            }
            
            let httpResponse = response as! NSHTTPURLResponse
            completionHandler(success: true, statusCode: httpResponse.statusCode)
        })
        
        // start task
        task.resume()
    }
    
    
    
}
