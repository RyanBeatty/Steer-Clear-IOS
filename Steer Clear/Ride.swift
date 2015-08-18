//
//  Ride.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation

class Ride {

    var dropoff_address:String
    var dropoff_time:String
    var end_latitude:Float
    var end_longitude:Float
    var id:Int
    var num_passengers:Int
    var pickup_address:String
    var pickup_time:String
    var start_latitude:Float
    var start_longitude:Float
    var travel_time:Int
    
    init(dropoff_address:String, dropoff_time:String, end_latitude:Float, end_longitude:Float,
        id:Int, num_passengers:Int, pickup_address:String, pickup_time:String, start_latitude:Float,
        start_longitude:Float, travel_time:Int) {
        
        self.dropoff_address = dropoff_address
        self.dropoff_time = dropoff_time
        self.end_latitude = end_latitude
        self.end_longitude = end_longitude
        self.id = id
        self.num_passengers = num_passengers
        self.pickup_address =  pickup_address
        self.pickup_time = pickup_time
        self.start_latitude = start_latitude
        self.start_longitude = start_longitude
        self.travel_time = travel_time
        
    }
    
    func toJSON() -> String {
        return "{\"ride\":{\"dropoff_address\":\(dropoff_address),\"dropoff_time\":\"\(dropoff_time)\",\"end_latitude\":\"\(end_latitude)\",\"end_longitude\":\"\(end_longitude)\",\"id\":\"\(id)\",\"num_passengers\":\"\(num_passengers)\",\"pickup_address\":\"\(pickup_address)\",\"pickup_time\":\"\(pickup_time)\",\"start_latitude\":\"\(start_latitude)\",\"start_longitude\":\"\(start_longitude)\",\"travel_time\":\"\(travel_time)\"}}"
    }
}