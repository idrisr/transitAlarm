//
//  StopAnnotation.swift
//  TransitAlarm
//
//  Created by id on 5/1/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import MapKit

class StopAnnotation: MKPointAnnotation {
    init(stop: Stop) {
        super.init()
        self.coordinate = stop.location2D
    }
}
