//
//  ViewController.swift
//  Uber
//
//  Created by Chris Harrison on 02/04/2018.
//  Copyright © 2018 Chris Harrison. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    
    var signupMode: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func topTapped(sender: Any) {
        
        guard
            let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != ""
        else {
            displayAlert(title: "Missing Information", message: "You must provide both an email and password")
            return
        }
        
        if signupMode {
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.displayAlert(title: "Error", message: error.localizedDescription)
                } else {
                    
                    
                    print("Signup Successful")
                    if self.riderDriverSwitch.isOn {
                        let request = Auth.auth().currentUser?.createProfileChangeRequest()
                        request?.displayName = "Driver"
                        request?.commitChanges(completion: nil)
                        self.performSegue(withIdentifier: "driverSegue", sender: nil)
                    } else {
                        let request = Auth.auth().currentUser?.createProfileChangeRequest()
                        request?.displayName = "Rider"
                        request?.commitChanges(completion: nil)
                        self.performSegue(withIdentifier: "riderSegue", sender: nil)
                    }
                    
                }
            }
            
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.displayAlert(title: "Error", message: error.localizedDescription)
                } else {
                    print("Login Successful")
                    
                    if user?.displayName == "Driver" {
                        self.performSegue(withIdentifier: "driverSegue", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "riderSegue", sender: nil)
                    }
                    
                }
                
            }
        }
        
        
    }
    
    @IBAction func bottomTapped(sender: Any) {
        if signupMode {
            topButton.setTitle("Login", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signupMode = false
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Login", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signupMode = true
        }
    }



}

