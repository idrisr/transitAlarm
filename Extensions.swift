//
//  Extensions.swift
//  TransitAlarm
//
//  Created by id on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation

extension Double {
    func metersToMiles() -> Double {
        return self * 0.000621371
    }

    func metersToFeet() -> Double {
        return self * 3.28084
    }

    func degreesToMeters() -> Double {
        // https://en.wikipedia.org/wiki/Decimal_degrees#precision
        return self * 111.32 * 1000
    }
}