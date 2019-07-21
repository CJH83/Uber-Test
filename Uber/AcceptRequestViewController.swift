//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Chris Harrison on 04/04/2018.
//  Copyright © 2018 Chris Harrison. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    @IBAction func acceptTapped(sender: Any) {
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLatitude": self.driverLocation.latitude, "driverLongitude": self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            
            guard let placemarks = placemarks else {
                return
            }
            
            if placemarks.count > 0 {
                let placemark = MKPlacemark(placemark: placemarks[0])
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = self.requestEmail
                let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: options)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(requestLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
        
        
    }
    
    
}
