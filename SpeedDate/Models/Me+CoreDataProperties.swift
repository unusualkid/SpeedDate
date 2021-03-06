//
//  Me+CoreDataProperties.swift
//  SpeedDate
//
//  Created by Kenneth Chen on 12/27/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreData


extension Me {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Me> {
        return NSFetchRequest<Me>(entityName: "Me")
    }

    @NSManaged public var birthday: String?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var lookingFor: String?
    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var city: String?

}
