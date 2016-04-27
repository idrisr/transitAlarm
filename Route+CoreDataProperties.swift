//
//  Route+CoreDataProperties.swift
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
import MapKit

extension Route {

    @NSManaged var color: String?
    @NSManaged var id: String?
    @NSManaged var long_name: String?
    @NSManaged var shape_id: String?
    @NSManaged var short_name: String?
    @NSManaged var text_color: String?
    @NSManaged var trip_id: String?
    @NSManaged var type: String?
    @NSManaged var url: String?
    @NSManaged var agency: Agency?
    @NSManaged var shapes: NSSet?
    @NSManaged var stops: NSSet?

    var shapeLine: MKPolyline {
        get {
            // sort shape by sequence
            let shapeSort = shapes!.sort( { Int(($0 as! Shape).sequence!) > Int(($1 as! Shape).sequence!) } )

            // get locations of shapes
            var locations = shapeSort.map { ($0 as! Shape).location2D }

            // create polyline
            return MKPolyline(coordinates: &locations, count: locations.count)
        }
    }
}
