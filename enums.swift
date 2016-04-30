//
//  enums.swift
//  TransitAlarm
//
//  Created by id on 4/29/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

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

enum sectionStatus: Int {
    case Selected
    case WaitingForSelection
    case NotReadyForSelection
}

struct SectionState {
    var section: tableSection
    var status: sectionStatus

    init(mySection: tableSection, myStatus: sectionStatus) {
        section = mySection
        status = myStatus
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
            SectionState(mySection: .Agency, myStatus: .WaitingForSelection),
            SectionState(mySection: .Route, myStatus: .NotReadyForSelection),
            SectionState(mySection: .Stop, myStatus: .NotReadyForSelection)
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