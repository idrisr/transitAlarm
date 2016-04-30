//
//  enums.swift
//  TransitAlarm
//
//  Created by id on 4/29/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation

enum tableSection: Int {
    case Agency
    case Route
    case Stop

    func entityName() -> String {
        switch self {
            case .Agency: return "Agency"
            case .Route:  return "Route"
            case .Stop:   return "Stop"
        }
    }

    func headerTitle() -> String {
        return self.entityName()
    }

    static let allValues = [Agency, Route, Stop]
}