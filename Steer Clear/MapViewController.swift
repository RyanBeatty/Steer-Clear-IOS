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
    var startLatitude = CLLocationDegrees()
    var startLongitude = CLLocationDegrees()
    var endLatitude = CLLocationDegrees()
    var endLongitude = CLLocationDegrees()
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var endLocationMarker: GMSMarker!
    var locationDetails = ""
    var destinationInput = false
    var cameFromSearch = false
    
    
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
        let gpaViewController = GooglePlacesAutocomplete(apiKey: "AIzaSyDd_lRDKvpH6ao8KmLTDmQPB4wdhxfuEys",placeType: .Address)
        print("hello")
       // let detalio = Place()
        gpaViewController.placeDelegate = self
        gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
        presentViewController(gpaViewController, animated: true, completion: nil)
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
        
        
    }
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        let googleController = GoooglePlaces()
        googleController.geocodeAddress(coordinate.latitude, long: coordinate.longitude)
        if segmentOutlet.selectedSegmentIndex == 0 {
            
            if locationMarker != nil {
                locationMarker.map = nil
            }
            
            locationMarker = GMSMarker(position: coordinate)
            locationMarker.appearAnimation = kGMSMarkerAnimationPop
            locationMarker.icon = GMSMarker.markerImageWithColor(pickupColor)
            locationMarker.title = "Pick Up"
            locationMarker.opacity = 0.75
            locationMarker.map = mapV
            startLatitude = coordinate.latitude
            startLongitude = coordinate.longitude
            

            
        } else{
            if endLocationMarker != nil {
                endLocationMarker.map = nil
            }
            endLocationMarker = GMSMarker(position: coordinate)
            endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
            endLocationMarker.icon = GMSMarker.markerImageWithColor(dropoffColor)
            endLocationMarker.title = "Drop Off"
            // endLocationMarker.snippet = "\(locationDetails)"
            print(locationDetails)
            endLocationMarker.opacity = 0.75
            endLocationMarker.map = mapV
            endLatitude = coordinate.latitude
            endLongitude = coordinate.longitude
            destinationInput = true
            

        }
        
        
        var placesClient: GMSPlacesClient?
        placesClient = GMSPlacesClient()
        //TODO  unhardcode this, add post request to google maps geocode
        
        placesClient!.lookUpPlaceID(googleController.fetchedID, callback: { (place, error) -> Void in
            if error != nil {
                println("lookup place id query error: \(error!.localizedDescription)")
                return
            }
            
            if place != nil && self.cameFromSearch == false {
                self.button.setTitle("\(place!.name)", forState: UIControlState.Normal)
                println("Place name \(place!.name)")
//                println("Place address \(place!.formattedAddress)")
//                println("Place placeID \(place!.placeID)")
//                println("Place attributions \(place!.attributions)")
            } else {
                println("No place details for \(googleController.fetchedID)")
            }
                            self.cameFromSearch = false
        })
    }

}

extension MapViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            self.mapV.camera = GMSCameraPosition.cameraWithLatitude(details.latitude, longitude: details.longitude, zoom: 15.0)
            let coordinate = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
            self.button.setTitle("\(place.description)", forState: UIControlState.Normal)
            self.cameFromSearch = true
            self.setupLocationMarker(coordinate)

            println(details)

        }
        println(place.description)
        println(place.id)
        self.locationDetails = place.description
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}