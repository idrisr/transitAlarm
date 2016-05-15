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
            let shapeLine = RouteLine(coordinates: &locations, count: locations.count)
            shapeLine.color = self.mapColor
            shapeLine.title = self.long_name
            return shapeLine
        }
    }

    var idNumeric: Int? {
        get {
            do {
                let string = id!
                let re = try NSRegularExpression(pattern: "[0-9]+", options: .CaseInsensitive)
                let matches = re.matchesInString(string, options: .ReportProgress, range: NSRange(location: 0, length: string.utf16.count))
                if matches.count > 0 {
                    let match = matches[0]
                    return Int((string as NSString).substringWithRange(match.rangeAtIndex(0)))!
                }
            } catch {
                return nil
            }
            return nil
        }
    }

    var stopAnnotations: [StopAnnotation] {
        get {
            return stops!.map{ ($0 as! Stop).annotation }
        }
    }

    var stopOverlays: [StopMapOverlay] {
        get {
            return stops!.map{ ($0 as! Stop).overlay }
        }
    }

    var mapTextColor: UIColor {
        if self.text_color != "" {
            return UIColor.hexColor(self.text_color!)
        } else {
            return UIColor.whiteColor()
        }
    }

    var mapColor: UIColor {
        if self.color != "" {
            return UIColor.hexColor(self.color!)
        } else {
            return UIColor.blueColor()
        }
    }

    var routeCenter: CLLocationCoordinate2D {
        let stopSort = stops!.sort( { Int(($0 as! Stop).sequence!) > Int(($1 as! Stop).sequence!) } )
        let midStop = stopSort[stopSort.count / 2] as! Stop
        return midStop.location2D
    }
}
