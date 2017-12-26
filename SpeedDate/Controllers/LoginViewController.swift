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

class LoginViewController: UIViewController {

    let delegate = UIApplication.shared.delegate as! AppDelegate
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Me")
        fr.sortDescriptors = [NSSortDescriptor(key: "email", ascending: true)]
        
        let context = delegate.stack.context
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let accessToken = AccessToken.current {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        print("Graph Request Succeeded: \(response)")
                        
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                }
                connection.start()
                
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

