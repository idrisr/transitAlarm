//
//  GeoFence.swift
//  TransitAlarm
//
//  Created by id on 5/7/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import CoreData
import MapKit
import UIKit

struct GeoFence {
    let overlay: MKCircle
    let region: CLCircularRegion

    init(stop: Stop) {
        let radius: CLLocationDistance = 300 // FIXME: Magic number
        self.overlay = MKCircle(centerCoordinate: stop.location2D, radius: radius)
        self.region = CLCircularRegion(center: stop.location2D, radius: radius, identifier: stop.name!)
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = false
    }
}
