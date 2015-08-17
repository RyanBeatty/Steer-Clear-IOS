//
//  Network.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Network {
    
    var responseStatus: Int = 0
    var responseFound = false
    
    func noNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }
    
    func register(username: String, password: String, phone: String) {
        var postData = NSMutableData(data: "username=\(username)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&phone=%2B1\(phone)".dataUsingEncoding(NSUTF8StringEncoding)!)
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/register")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        var responso: Int = 0
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                responso = httpResponse!.statusCode
                
            }
            self.responseStatus = responso
            if self.responseStatus != 0 {
                self.responseFound = true
                print("Response Found \n")
            }
        })
        dataTask.resume()
    
    }
    
    func login(username: String, password: String) {
//        if email.rangeOfString("@email.wm.edu") != nil{
//            println("Not appending @")
//        } else {
//            email = email + "@email.wm.edu"
//            print(email)
//        }
        
        var postData = NSMutableData(data: "username=\(username)".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/login")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        var responso: Int = 0
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                responso = httpResponse!.statusCode
                
            }
            self.responseStatus = responso
            if self.responseStatus != 0 {
                self.responseFound = true
                print("Response Found \n")
            }
        })
        
        dataTask.resume()
    }
    
    func add(start_lat: String, start_long: String, end_lat: String, end_long: String, numOfPassengers :String) {
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
    
    func sendRequest(){
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
    
    func logout(){
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

 
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    var fetchedID: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    var yes = true
    
    func geocodeAddress(lat: Double, long: Double) {
        if yes == true {
            let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys"
            
            var geocodeURLString = baseURLGeocode
            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let geocodeURL = NSURL(string: geocodeURLString)
            
            
            let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
            
            var error: NSError?
            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
            
            if (error != nil) {
                println(error)
                //       completionHandler(status: "", success: false)
            }
            else {
                // Get the response status.
                let status = dictionary["status"] as! String
                
                if status == "OK" {
                    let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                    self.lookupAddressResults = allResults[0]
                    
                    // Keep the most important values.
                    self.fetchedFormattedAddress = self.lookupAddressResults["place_id"]as! String
                    //print(self.fetchedFormattedAddress)
                    self.fetchedID = self.fetchedFormattedAddress
                }
            }
        }
    }
}


