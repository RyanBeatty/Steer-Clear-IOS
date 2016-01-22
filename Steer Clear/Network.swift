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
import SwiftyJSON

class Network {
    
    var settings = Settings()
    
    func noNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    var fetchedID: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    var yes = true
    
    func geocodeAddress(lat: Double, long: Double) {
        if yes == true {
            
            let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)"
            if let url = NSURL(string: baseURLGeocode) {
                if let data = try? NSData(contentsOfURL: url, options: []) {
                    let json = JSON(data: data)
                    
                    if json["status"] == "OK" {
                        let placeID = String(json["results"][0]["place_id"])
                        //print(self.fetchedFormattedAddress)
                        self.fetchedID = placeID
                        
                    }
                }
                
            }
        }
    }
    
    /*
    checkUpdate
    ------
    Checks to see if Steer Clear service is running
    
    :completionHandler: callback method that takes a success flag and a string message
    */
    func checkUpdate(completionHandler: (success: Bool, message: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://itunes.apple.com/lookup?id=1036506994")!)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            // if there was an error, request failed
            if(error != nil || response == nil || data == nil) {
                completionHandler(success: true, message: "There was a network error while checking app version.")
                return
            }
            
            // else check the request status code to see if logging out succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                let json = JSON(data: data!)
                // get ride request data
                if json["results"][0]["version"] != nil {
                    let fetchedAppVersion = Double((json["results"][0]["version"].string)!)
                    let currentAppVersion = Double(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
                    print("-----")
                    print("-----")
                    print(fetchedAppVersion)
                    print(currentAppVersion)
                    print("**Network: Currently running v\(currentAppVersion!). Latest release v\(fetchedAppVersion!).")
                    if fetchedAppVersion == currentAppVersion {
                        completionHandler(success: true, message: "You are using the latest version of the app")
                    } else {
                        completionHandler(success: false, message: "You are NOT using the latest version of the app")
                    }
                } else {
                    completionHandler(success: true, message: "Failed to find app version")
                }
               
            default:
                completionHandler(success: true, message: "Failed to find app version")
            }
        })
        
        dataTask.resume()
    }
}