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
            
//            var geocodeURLString = baseURLGeocode
//            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let geocodeURL = NSURL(string: baseURLGeocode)
            
            
            let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
            
            var error: NSError?
//            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
            
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print(dictionary)
            } catch let error as NSError {
                print(error)
            }
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


