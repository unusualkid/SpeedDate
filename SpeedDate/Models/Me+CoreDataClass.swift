//
//  Me+CoreDataClass.swift
//  SpeedDate
//
//  Created by Kenneth Chen on 12/26/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Me)
public class Me: NSManagedObject {
    convenience init(id: String, name: String, birthday: NSDate, gender: String, lookingFor: String, email: String, context: NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Me", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.name = name
            self.birthday = birthday
            self.gender = gender
            self.lookingFor = lookingFor
            self.email = email
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
