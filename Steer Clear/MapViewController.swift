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

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var button: UIButton!
    @IBOutlet var destinationButton: UIButton!
    @IBOutlet var rideButton: UIButton!
    @IBOutlet var myLocationButtonOutlet: UIButton!
    @IBOutlet var sendCoordinateButton: UIButton!
    
    @IBOutlet var mapV: GMSMapView!
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var endLocationMarker: GMSMarker!
    var locationDetails = ""
    
    
    
    let dropoffColor = UIColor(hue: 0, saturation: 0.47, brightness: 0.84, alpha: 1.0) /* #d67171 */
    let pickupColor = UIColor(hue: 0.4806, saturation: 0.47, brightness: 0.76, alpha: 1.0) /* #66c1b7 */
    
    @IBAction func segmentControlSwitch(sender: AnyObject) {
        
        switch segmentOutlet.selectedSegmentIndex
        {
        case 0:
            button.backgroundColor = pickupColor
            segmentOutlet.tintColor = pickupColor
            myLocationButtonOutlet.backgroundColor = pickupColor
            sendCoordinateButton.backgroundColor = pickupColor
        case 1:
            button.backgroundColor = dropoffColor
            segmentOutlet.tintColor = dropoffColor
            myLocationButtonOutlet.backgroundColor = dropoffColor
            sendCoordinateButton.backgroundColor = dropoffColor
        default:
            break; 
        }
    }
    
    
    @IBAction func myLocationButton(sender: AnyObject) {
        let myLocation = locationManager.location
        mapV.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0)
        self.setupLocationMarker(myLocation.coordinate)
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys",
            placeType: .Address
        )
        
        gpaViewController.placeDelegate = self
        gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func hailRide(sender: AnyObject) {
        let addRideController = AddRide()
        addRideController.add(String(format:"%.6f", latitude),start_long: String(format:"%.6f", longitude))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapV.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        mapV.delegate = self
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapV.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
            mapV.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0)
            //mapV.settings.myLocationButton = true
            self.setupLocationMarker(myLocation.coordinate)
            didFindMyLocation = true
        }
    }
    //This function detects a long press on the map and places a marker at the coordinates of the long press.
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        println(1)
        //Set variable to latitude of didLongPressAtCoordinate
        var lat = coordinate.latitude
        
        //Set variable to longitude of didLongPressAtCoordinate
        var long = coordinate.longitude
        println(2)
        //Feed position to mapMarker
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.setupLocationMarker(coordinate)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func setupButtons() {
        button.layer.shadowOpacity = 0.5
        
        myLocationButtonOutlet.layer.cornerRadius = 0.5 * myLocationButtonOutlet.bounds.size.width
        myLocationButtonOutlet.layer.shadowOpacity = 0.5
        
        sendCoordinateButton.layer.cornerRadius = 0.5 * sendCoordinateButton.bounds.size.width
        sendCoordinateButton.layer.shadowOpacity = 0.5
        
        
    }
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {

        if segmentOutlet.selectedSegmentIndex == 0 {
            
            if endLocationMarker != nil {
                endLocationMarker.map = nil
            }
            endLocationMarker = GMSMarker(position: coordinate)
            endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
            endLocationMarker.icon = GMSMarker.markerImageWithColor(pickupColor)
            endLocationMarker.title = "Pick Up"
           // endLocationMarker.snippet = "\(locationDetails)"
            print(locationDetails)
            endLocationMarker.opacity = 0.75
            endLocationMarker.map = mapV
            
            
        } else{
            if locationMarker != nil {
                locationMarker.map = nil
            }
            locationMarker = GMSMarker(position: coordinate)
            locationMarker.appearAnimation = kGMSMarkerAnimationPop
            locationMarker.icon = GMSMarker.markerImageWithColor(dropoffColor)
            endLocationMarker.title = "Drop Off"
            locationMarker.opacity = 0.75
            
            locationMarker.map = mapV

        }
        
    }
    
}

extension MapViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            self.latitude = details.latitude
            self.longitude = details.longitude
            self.mapV.camera = GMSCameraPosition.cameraWithLatitude(details.latitude, longitude: details.longitude, zoom: 15.0)
            let coordinate = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
            self.button.setTitle("\(place.description)", forState: UIControlState.Normal)
            self.setupLocationMarker(coordinate)
            println(details)
        }
        println(place.description)
        self.locationDetails = place.description
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}