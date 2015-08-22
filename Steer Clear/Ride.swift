//
//  Ride.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//  *** Currently not in use, Possible in future development ***

import Foundation

class Ride: Equatable {

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

/*
    ==
    --
    compares 2 Ride objects and checks if they are equal
*/
func ==(lhs: Ride, rhs: Ride) -> Bool {
    return lhs.id == rhs.id &&
           lhs.numPassengers == rhs.numPassengers &&
           lhs.pickupAddress == rhs.pickupAddress &&
           lhs.dropoffAddress == rhs.dropoffAddress &&
           lhs.pickupTime == rhs.pickupTime
}