//
//  UIColor+hexString.swift
//  TransitAlarm
//
//  Created by id on 5/15/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

extension UIColor {
    class func hexColor(hexString: String) -> UIColor {
        let val = Int(hexString, radix: 16)!

        let red   = CGFloat((val & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((val & 0x00FF00) >> 8)  / 0xFF
        let blue  = CGFloat((val & 0x0000FF) >> 0)  / 0xFF

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
