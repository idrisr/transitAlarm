//
//  Stop+CoreDataProperties.swift
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
import MapKit

extension Stop {

    @NSManaged var id: String?

    // TODO: change these to the right type in core data to avoid constant casting
    @NSManaged var latitude:     String?
    @NSManaged var longitude:    String?
    @NSManaged var name:         String?
    @NSManaged var sequence:     String?
    @NSManaged var trip_id:      String?
    @NSManaged var route:        Route?

    var location: CLLocation {
        get {
            let latitude = self.getLatitude()
            let longitude = self.getLongitude()
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    var annotation: MKPointAnnotation {
        get {
            // TODO: better way?
            let tmp = MKPointAnnotation()
            tmp.coordinate = self.location2D
            return tmp
        }
    }

    var location2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.getLatitude(), self.getLongitude())
    }

    func getLatitude() -> CLLocationDegrees {
        return Double(self.latitude!)!
    }

    func getLongitude() -> CLLocationDegrees {
        return Double(self.longitude!)!
    }
}
