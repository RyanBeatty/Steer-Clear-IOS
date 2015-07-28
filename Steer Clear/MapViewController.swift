//
//  MapViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright © 2015 Paradoxium. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import QuartzCore

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var button: UIButton!

    @IBOutlet var destinationButton: UIButton!
    
    @IBOutlet var rideButton: UIButton!
    
    @IBOutlet var mapV: GMSMapView!
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var locationManager = CLLocationManager()
    
    var didFindMyLocation = false
    
    @IBAction func searchButton(sender: AnyObject) {
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys",
            placeType: .Address
        )
        
        gpaViewController.placeDelegate = self
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func hailRide(sender: AnyObject) {
        let addRideController = AddRide()
        addRideController.add(String(format:"%.6f", latitude),start_long: String(format:"%.6f", longitude))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOffset = CGSizeMake(1, 1)
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 1.0
        
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613, zoom: 8.0)
        mapV.camera = camera
        self.mapV.sendSubviewToBack(mapV)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapV.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        destinationButton.layer.shadowColor = UIColor.blackColor().CGColor
        destinationButton.layer.shadowOffset = CGSizeMake(1, 1)
        destinationButton.layer.shadowRadius = 1
        destinationButton.layer.shadowOpacity = 1.0
        
        rideButton.layer.shadowColor = UIColor.blackColor().CGColor
        rideButton.layer.shadowOffset = CGSizeMake(1, 1)
        rideButton.layer.shadowRadius = 1
        rideButton.layer.shadowOpacity = 1.0
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapV.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
            mapV.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapV.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "logoutRider" {
//            let logoutController = Logout()
//            logoutController.logout()
//            print(2)
//        }
//    }
    
}

extension MapViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        println(place.description)
        
        place.getDetails { details in
            self.latitude = details.latitude
            self.longitude = details.longitude
            println(details)
        }
    }
    
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}