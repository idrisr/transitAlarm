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

enum direction: Int {
    case Up
    case Down
}

enum tableHeights: Int {
    case Row
    case Header

    func height() -> Int {
        switch self {
        case .Row: return 50
        case .Header : return 20
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
            case .Route:  return 4
            case .Stop:   return 6
        }
    }

    static let allValues = [Agency, Route, Stop]
}

enum sectionStatus: Int {
    case Selected
    case WaitingForSelection
    case NotReadyForSelection
}

struct SectionState {
    var section: tableSection
    var status: sectionStatus
    var selection: Int?

    init(mySection: tableSection, myStatus: sectionStatus, mySelection: Int?) {
        section = mySection
        status = myStatus
        selection = mySelection
    }
}

class TableHandler {
    var agency: Agency?
    var route: Route?
    var stop: Stop?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?

    var sectionStates: [SectionState]

    init() {
        moc = appDelegate.managedObjectContext
        sectionStates = [
            SectionState(mySection: .Agency, myStatus: .WaitingForSelection, mySelection: nil),
            SectionState(mySection: .Route, myStatus: .NotReadyForSelection, mySelection: nil),
            SectionState(mySection: .Stop, myStatus: .NotReadyForSelection,  mySelection:nil)
        ]
    }

    var sections: ([Agency]?, [Route]?, [Stop]?)? {
        get {
            return (agencys: agencys, routes: routes, stops: stops)
        }
    }

    var agencys: [Agency]? {
        get {
            let entity = tableSection.Agency.entityName()
            let request = NSFetchRequest.init(entityName: entity)

            do {
                let result = try self.moc!.executeFetchRequest(request)
                return result as? [Agency]
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        }
    }

    var routes: [Route]? {
        get {
            let entity = tableSection.Route.entityName()
            let request = NSFetchRequest.init(entityName: entity)

            do {
                let result = try self.moc!.executeFetchRequest(request)
                return result as? [Route]
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        }
    }

    var stops: [Stop]? {
        get {
            let entity = tableSection.Stop.entityName()
            let request = NSFetchRequest.init(entityName: entity)

            do {
                let result = try self.moc!.executeFetchRequest(request)
                return result as? [Stop]
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        }
    }
}