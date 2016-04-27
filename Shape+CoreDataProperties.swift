//
//  Shape+CoreDataProperties.swift
//  TransitAlarm
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Shape {

    @NSManaged var id: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var sequence: String?
    @NSManaged var route: Route?

    var location2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(self.getLatitude(), self.getLongitude())
        }
    }

    func getLatitude() -> CLLocationDegrees {
        return Double(self.latitude!)!
    }

    func getLongitude() -> CLLocationDegrees {
        return Double(self.longitude!)!
    }

    func getSequence() -> Int {
        return Int(self.sequence!)!
    }
}
