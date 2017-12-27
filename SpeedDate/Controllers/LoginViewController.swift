//
//  LoginViewController.swift
//  SpeedDate
//
//  Created by Kenneth Chen on 12/26/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import UIKit
import CoreData
import FacebookLogin
import FacebookCore
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    let delegate = UIApplication.shared.delegate as! AppDelegate
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Me")
        fr.sortDescriptors = [NSSortDescriptor(key: "email", ascending: true)]
        
        let context = delegate.stack.context
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let accessToken = AccessToken.current {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile, .userBirthday, .userLocation, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                let connection = GraphRequestConnection()
                let graphrequest = GraphRequest(graphPath: "/me",
                                                parameters: ["fields": "\(FacebookConstants.Id), \(FacebookConstants.Name), \(FacebookConstants.Birthday), \(FacebookConstants.Gender), \(FacebookConstants.Email), \(FacebookConstants.Location)"],
                                                accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
                
                connection.add(graphrequest) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        print("Graph Request Succeeded: \(response)")
                        
                        /* GUARD: Is "gender" key in our response? */
                        guard let gender = response.dictionaryValue![FacebookConstants.Gender] as? String else {
                            print("Cannot find keys '\(FacebookConstants.Gender)' in \(response)")
                            return
                        }
                        
                        /* GUARD: Is "id" key in our response? */
                        guard let id = response.dictionaryValue![FacebookConstants.Id] as? String else {
                            print("Cannot find keys '\(FacebookConstants.Id)' in \(response)")
                            return
                        }
                        
                        /* GUARD: Is "name" key in our response? */
                        guard let name = response.dictionaryValue![FacebookConstants.Name] as? String else {
                            print("Cannot find keys '\(FacebookConstants.Name)' in \(response)")
                            return
                        }
                        
                        /* GUARD: Is "birthday" key in our response? */
                        guard let birthday = response.dictionaryValue![FacebookConstants.Birthday] as? String else {
                            print("Cannot find keys '\(FacebookConstants.Birthday)' in \(response)")
                            return
                        }

                        /* GUARD: Is "location" key in our response? */
                        guard let locationDictionary = response.dictionaryValue![FacebookConstants.Location] as? [String: AnyObject] else {
                            print("Cannot find keys '\(FacebookConstants.Location)' in \(response)")
                            return
                        }
                        
                        guard let location = locationDictionary["name"] as? String else {
                            print("Cannot find keys 'name' in \(locationDictionary)")
                            return
                        }
                        
                        /* GUARD: Is "email" key in our response? */
                        guard let email = response.dictionaryValue![FacebookConstants.Email] as? String else {
                            print("Cannot find keys '\(FacebookConstants.Email)' in \(response)")
                            return
                        }
                        
                        let me = Me(id: id, name: name, birthday: birthday, gender: gender, email: email, city: location, context: self.delegate.stack.context)
                        
                        print("me: \(me)")
                        
                        
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                    
                }
                connection.start()
                self.performSegue(withIdentifier: "showNavigationController", sender: self)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            var locValue: CLLocationCoordinate2D = coordinate
            print("location = \(locValue.latitude) \(locValue.longitude)")
        }
    }
}

