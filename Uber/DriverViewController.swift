//
//  DriverViewController.swift
//  Uber
//
//  Created by Chris Harrison on 03/04/2018.
//  Copyright © 2018 Chris Harrison. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequests: [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                if let latitude = rideRequestDictionary["driverLatitude"] as? Double {
                    
                } else {
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        let snapshot = rideRequests[indexPath.row]
        if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
            guard let email = rideRequestDictionary["email"] as? String else {
                return cell
            }
            
            guard
                let latitude = rideRequestDictionary["latitude"] as? Double,
                let longitude = rideRequestDictionary["longitude"] as? Double
            else {
                return cell
            }
            
            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
            let riderCLLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
            
            let roundedDistance = round(distance * 100) / 100
            cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let acceptVC = segue.destination as? AcceptRequestViewController else {
            return
        }
        
        guard let snapshot = sender as? DataSnapshot else {
            return
        }
        guard
            let rideRequestDictionary = snapshot.value as? [String: AnyObject],
            let email = rideRequestDictionary["email"] as? String,
            let latitude = rideRequestDictionary["latitude"] as? Double,
            let longitude = rideRequestDictionary["longitude"] as? Double
        else {
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        acceptVC.requestEmail = email
        acceptVC.requestLocation = location
        acceptVC.driverLocation = driverLocation
        
    }
    
    @IBAction func logoutTapped(sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
