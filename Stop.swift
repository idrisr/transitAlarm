//
//  Stop.swift
//  TransitAlarm
//
//  Created by id on 4/18/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation
import CoreLocation
import SWXMLHash

struct Stop {
    var stop_id: Int?
    var direction: String? // enum?
    var stop_name: String?
    var station_name: String?
    var map_id: Int
    var ada: Bool

    var red: Bool
    var blue: Bool
    var green: Bool
    var brown: Bool
    var purple: Bool
    var purple_exp: Bool
    var yellow: Bool
    var pink: Bool
    var orange: Bool
    var location: CLLocation

//    <location latitude="41.768367" longitude="-87.625724" needs_recoding="false"/>
    init(xmlData: XMLIndexer) {
        stop_id = 123
        direction = "asdf"
        stop_name = "asdf"
        station_name = "asdf"
        map_id = 1
        ada = false

        red = false
        blue = false
        green = false
        brown = false
        purple = false
        purple_exp = false
        yellow = false
        pink = false
        orange = false
        location = CLLocation()
    }
}