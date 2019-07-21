//
//  RiderViewController.swift
//  Uber
//
//  Created by Chris Harrison on 03/04/2018.
//  Copyright © 2018 Chris Harrison. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled: Bool = false
    var driverLocation = CLLocationCoordinate2D()
    var driverOnWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
            
            self.uberHasBeenCalled = true
            self.callAnUberButton.setTitle("Cancel Uber", for: .normal)
            Database.database().reference().child("RideRequests").removeAllObservers()
            
            if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                if let driverLatitude = rideRequestDictionary["driverLatitude"] as? Double {
                    if let driverLongitude = rideRequestDictionary["driverLongitude"] as? Double {
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLatitude, longitude: driverLongitude)
                        self.driverOnWay = true
                        self.displayDriverAndRider()
                        
                        guard let email = Auth.auth().currentUser?.email else {
                            return
                        }
                        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                            
                            if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                                if let driverLatitude = rideRequestDictionary["driverLatitude"] as? Double {
                                    if let driverLongitude = rideRequestDictionary["driverLongitude"] as? Double {
                                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLatitude, longitude: driverLongitude)
                                        self.driverOnWay = true
                                        self.displayDriverAndRider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        
        
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        callAnUberButton.setTitle("Your driver is \(roundedDistance)km away!", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latitudeDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 * 2 + 0.005
        let longitudeDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 * 2 + 0.005
        let region = MKCoordinateRegionMake(userLocation, MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        map.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your Location"
        map.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your Driver"
        map.addAnnotation(driverAnnotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = manager.location?.coordinate else {
            return
        }
        
        let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        userLocation = center
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "Your Location"
        map.addAnnotation(annotation)
        
        if uberHasBeenCalled {
            displayDriverAndRider()
            
        } else {
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            map.addAnnotation(annotation)
        }
        
        
    }
    
    @IBAction func logoutTapped(sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUberTapped(sender: Any) {
        
        if !driverOnWay {
            
            guard let email = Auth.auth().currentUser?.email else {
                return
            }
            
            if uberHasBeenCalled {
                
                uberHasBeenCalled = false
                callAnUberButton.setTitle("Call an Uber", for: .normal)
                
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
                
                
                
            } else {
                let rideRequestDictionary: Dictionary<String, Any> = ["email" : email, "latitude" : userLocation.latitude, "longitude" : userLocation.longitude]
                
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                
                uberHasBeenCalled = true
                callAnUberButton.setTitle("Cancel Uber", for: .normal)
            }
        }
        
    }
    
    
}
