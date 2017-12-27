//
//  Me+CoreDataClass.swift
//  SpeedDate
//
//  Created by Kenneth Chen on 12/26/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreLocation
import CoreData

@objc(Me)
public class Me: NSManagedObject {
    convenience init(id: String, name: String, birthday: String, gender: String, email: String, city: String, context: NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Me", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.name = name
            self.birthday = birthday
            self.gender = gender
            self.lookingFor = gender == "male" ? "female" : "male"
            self.city = city
            CLGeocoder().geocodeAddressString(city, completionHandler: { (placemarks, error) in
                print("city: \(city)")
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0] as! CLPlacemark
                        print("placemark.localition: \(placemark.location)")
                        self.lat = placemark.location?.coordinate.latitude ?? 0
                        self.lon = placemark.location?.coordinate.longitude ?? 0
                    }
                }
            })
            
            self.email = email
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
