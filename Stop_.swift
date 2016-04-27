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

extension UIColor {
    class func pinkColor() -> UIColor {
        return UIColor(red: 255/256, green: 192/256, blue: 203/256, alpha: 1.0)
    }
}

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

enum CTATrainLine: Int {
    case Red
    case Blue
    case Green
    case Brown
    case Purple
    case PurpleExpress
    case Yellow
    case Pink
    case Orange

    func name() -> String {
        switch self {
            case .Red:           return "Red"
            case .Blue:          return "Blue"
            case .Green:         return "Green"
            case .Brown:         return "Brown"
            case .Purple:        return "Purple"
            case .PurpleExpress: return "Purple Express"
            case .Yellow:        return "Yellow"
            case .Pink:          return "Pink"
            case .Orange:        return "Orange"
        }
    }

    func headerName() -> String {
        return "\(self.name()) Line"
    }

    func xmlElementName() -> String {
        switch self {
            case .Red:           return "red"
            case .Blue:          return "blue"
            case .Green:         return "g"
            case .Brown:         return "brn"
            case .Purple:        return "p"
            case .PurpleExpress: return "pexp"
            case .Yellow:        return "y"
            case .Pink:          return "pnk"
            case .Orange:        return "o"
        }
    }

    func color() -> UIColor {
        switch self {
            case .Red:           return UIColor.redColor()
            case .Blue:          return UIColor.blueColor()
            case .Green:         return UIColor.greenColor()
            case .Brown:         return UIColor.brownColor()
            case .Purple:        return UIColor.purpleColor()
            case .PurpleExpress: return UIColor.purpleColor()
            case .Yellow:        return UIColor.yellowColor()
            case .Pink:          return UIColor.pinkColor()
            case .Orange:        return UIColor.orangeColor()
        }
    }

    // must be a better way. what if we add a value to the enum?
    static let allValues = [Red, Blue, Green, Brown, Purple, PurpleExpress, Yellow, Pink, Orange]
}

struct Stop_ {
    var stop_id: Int?
    var direction: String? // enum?
    var stop_name: String?
    var station_name: String?
    var map_id: Int?
    var ada: Bool?
    var location: CLLocation
    var lines: [CTATrainLine]
    
    init(xmlData: XMLIndexer) {
        // FIXME: add xml element values to enum somehow
        stop_id      = xmlData["stop_id"].element!.text!.toInt()
        direction    = xmlData["direction_id"].element!.text
        stop_name    = xmlData["stop_name"].element!.text
        station_name = xmlData["station_name"].element!.text
        map_id       = xmlData["map_id"].element!.text?.toInt()
        ada          = xmlData["ada"].element!.text!.toBool()
        lines = [CTATrainLine]()

        let latitude = xmlData["location"].element?.attributes["latitude"]?.toDouble()
        let longitude = xmlData["location"].element?.attributes["longitude"]?.toDouble()
        location     = CLLocation(latitude: latitude!, longitude: longitude!)

        for trainLine in CTATrainLine.allValues {
            if xmlData[trainLine.xmlElementName()].element?.text!.toBool() == true {
                lines.append(trainLine)
            }
        }
    }
}
