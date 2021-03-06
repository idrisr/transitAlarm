//
//  enums.swift
//  TransitAlarm
//
//  Created by id on 4/29/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }

    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

enum viewControllerIdentifiers: String {
    case Center
    case Search
    case Favorites

    func identifier() -> String {
        switch self  {
            case Center: return "CenterViewController"
            case Search: return "SearchViewController"
            case Favorites: return "FavoritesViewController"
        }
    }
}

enum direction: Int {
    case Up
    case Down
}

enum tableHeights: Int {
    case Row
    case Header

    func height() -> CGFloat {
        switch self {
            case .Row: return 40.0
            case .Header : return 20.0
        }
    }

    func minVisible() -> Int {
        switch self {
            case .Row: return 1
            case .Header : return 1
        }
    }
}

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

    func sections() -> [String] {
        switch self {
            case .Agency: return ["Agency"]
            case .Route:  return ["Agency", "Route"]
            case .Stop:   return ["Agency", "Route", "Stop"]
        }
    }

    func headerTitle() -> String {
        return self.entityName()
    }

    func minRows() -> Int {
        switch self {
            case .Agency: return 3
            case .Route:  return 5
            case .Stop:   return 7
        }
    }

    static let allValues = [Agency, Route, Stop]
}