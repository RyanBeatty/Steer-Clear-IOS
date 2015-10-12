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
}