//
//  StopMapOverlay.swift
//  TransitAlarm
//
//  Created by id on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import MapKit
import SwiftHEXColors

class StopMapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var color: UIColor

    init(stop: Stop) {
        self.coordinate = stop.location2D
        self.boundingMapRect = stop.boundingMapRect
        self.color = stop.route!.mapColor
        super.init()
    }
}
