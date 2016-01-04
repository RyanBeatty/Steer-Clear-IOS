//
//  Settings.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 9/2/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Settings: UIViewController {

    // Google Maps SDK for iOS version API Key
    // Full functionality of app requires API key, please generate.
    
    let GMSAPIKEY = ""
    
    // Custom UIColor
    
    let spiritGold = UIColor(red:0.94, green:0.70, blue:0.14, alpha:1.0)
    let wmGreen = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
    
    // Geofence center coordinate Wren Building (~3 mile radius)
    
    let geofenceCenter = CLLocationCoordinate2D(latitude: 37.271689 , longitude: -76.714215)
    
    let zoom: Float = 17.0
    
    let bearing: CLLocationDirection = 30
    let viewingAngle: Double = 45
}
