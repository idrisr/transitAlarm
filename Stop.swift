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

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }

    func toInt() -> Int? {
        return Int(self)
    }

    func toDouble() -> Double? {
        return Double(self)
    }
}

struct Stop {
    var stop_id: Int?
    var direction: String? // enum?
    var stop_name: String?
    var station_name: String?
    var map_id: Int?
    var ada: Bool?

    var red: Bool?
    var blue: Bool?
    var green: Bool?
    var brown: Bool?
    var purple: Bool?
    var purple_exp: Bool?
    var yellow: Bool?
    var pink: Bool?
    var orange: Bool?
    var location: CLLocation

    init(xmlData: XMLIndexer) {
        stop_id      = xmlData["stop_id"].element!.text!.toInt()
        direction    = xmlData["direction_id"].element!.text
        stop_name    = xmlData["stop_name"].element!.text
        station_name = xmlData["station_name"].element!.text
        map_id       = xmlData["map_id"].element!.text?.toInt()
        ada          = xmlData["ada"].element!.text!.toBool()
        red          = xmlData["red"].element?.text!.toBool()
        blue         = xmlData["blue"].element?.text!.toBool()
        green        = xmlData["g"].element?.text!.toBool()
        brown        = xmlData["brn"].element?.text!.toBool()
        purple       = xmlData["p"].element?.text!.toBool()
        purple_exp   = xmlData["pexp"].element?.text!.toBool()
        yellow       = xmlData["y"].element?.text!.toBool()
        pink         = xmlData["pnk"].element?.text!.toBool()
        orange       = xmlData["o"].element?.text!.toBool()
        let latitude = xmlData["location"].element?.attributes["latitude"]?.toDouble()
        let longitude = xmlData["location"].element?.attributes["longitude"]?.toDouble()
        location     = CLLocation(latitude: latitude!, longitude: longitude!)
    }
}
