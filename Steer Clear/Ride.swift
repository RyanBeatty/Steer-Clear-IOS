//
//  Ride.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//  *** Currently not in use, Possible in future development ***

import Foundation

class Ride {

    var id:Int
    var numPassengers:Int
    var pickupAddress:String
    var dropoffAddress:String
    var pickupTime:String
    
    init(id: Int, numPassengers: Int, pickupAddress: String, dropoffAddress: String, pickupTime: String) {
        self.id = id
        self.numPassengers = numPassengers
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.pickupTime = pickupTime
    }
}