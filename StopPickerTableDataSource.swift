//
//  StopPickerTableDataSource.swift
//  TransitAlarm
//
//  Created by id on 4/30/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

class StopPickerTableDataSource: NSObject,
                                UITableViewDataSource,
                                UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?

    // somehow all these arrays should be in a struct/class of their own.
    var agencys = [Agency]()
    var routes = [Route]()
    var stops = [Stop]()

    var sections = ["Agency"]

    override init() {
        super.init()
        moc = appDelegate.managedObjectContext
        self.agencys = self.getAgencys()!
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableSection(rawValue: section)! {
            case .Agency:
                return self.agencys.count

            case .Route:
                return self.routes.count

            case .Stop:
                return self.stops.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch tableSection(rawValue: indexPath.section)! {
            case .Agency:
                let reuseID = "agencyCell"
                let agency = self.agencys[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
                cell.textLabel?.text = agency.name
                return cell

            case .Route:
                let reuseID = "agencyCell"
                let route = self.routes[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
                cell.textLabel?.text = route.long_name
                return cell

            case .Stop:
                let reuseID = "agencyCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
                let stop = self.stops[indexPath.row]
                cell.textLabel?.text = stop.name
                return cell
            }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection: Int) -> String? {
        return tableSection(rawValue: titleForHeaderInSection)!.headerTitle()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count;
    }

    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        var rowsToDelete     = [NSIndexPath]()
        var rowsToInsert     = [NSIndexPath]()
        var sectionsToDelete = NSIndexSet()
        var sectionsToInsert = NSIndexSet()

        switch tableSection(rawValue: indexPath.section)! {
        case .Agency:
            // from one to many agencys
            if self.agencys.count == 1 {
                let existingAgency = self.agencys.first
                self.agencys = self.getAgencys()! // change this to return something so it's explicit
                self.agencys.sortInPlace({$0.name < $1.name})

                sectionsToDelete = NSIndexSet(indexesInRange: NSMakeRange(1, self.sections.count - 1))
                self.sections = ["Agency"]

                for i in 0..<agencys.count {
                    if agencys[i] != existingAgency {
                        rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
                    }
                }

            } else {
            // from many to one agency
                self.sections = ["Agency", "Routes"]
                let agency = self.agencys[indexPath.row]
                self.routes = agency.routes?.allObjects as! [Route]
                self.routes.sortInPlace({$0.long_name < $1.long_name})
                sectionsToInsert = NSIndexSet(index: 1)

                // remove unselected agencies
                var agencysToRemove = [Agency]()
                for i in 0..<self.agencys.count {
                    if i != indexPath.row {
                        rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                        agencysToRemove.append(self.agencys[i])
                    }
                }
                self.agencys.removeObjectsInArray(agencysToRemove)
            }

        case .Route:
            // from one to many routes
            if self.routes.count == 1 {
                self.sections = ["Agency", "Routes"]
                let existingRoute = self.routes.first
                self.routes = self.agencys.first?.routes?.allObjects as! [Route]
                self.routes.sortInPlace({$0.long_name < $1.long_name})

                sectionsToDelete = NSIndexSet(index: 2) // use enum instead of magic number

                for i in 0..<self.routes.count {
                    if routes[i] != existingRoute {
                        rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
                    }
                }
            } else {
            // from many to one routes
                self.sections = ["Agency", "Routes", "Stops"]
                let route = self.routes[indexPath.row]
                self.stops = route.stops?.allObjects as! [Stop]
                self.stops.sortInPlace({Int($0.sequence!) < Int($1.sequence!)})
                sectionsToInsert = NSIndexSet(index: 2)

                // remove unselected agencies
                var routesToRemove = [Route]()
                for i in 0..<self.routes.count {
                    if i != indexPath.row {
                        rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                        routesToRemove.append(self.routes[i])
                    }
                }
                self.routes.removeObjectsInArray(routesToRemove)
            }

        case .Stop:
            // from one to many stops
            if self.stops.count == 1 {
                self.sections = ["Agency", "Routes", "Stops"]
                let existingStop = self.stops.first
                self.stops = self.routes.first?.stops?.allObjects as! [Stop]
                self.stops.sortInPlace({Int($0.sequence!) < Int($1.sequence!)})

                for i in 0..<self.stops.count {
                    if stops[i] != existingStop {
                        rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
                    }
                }
            } else {
            // from many to one stops
                self.sections = ["Agency", "Routes", "Stops"]

                // remove unselected agencies
                var stopsToRemove = [Stop]()
                for i in 0..<self.stops.count {
                    if i != indexPath.row {
                        rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                        stopsToRemove.append(self.stops[i])
                    }
                }
                self.stops.removeObjectsInArray(stopsToRemove)
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(rowsToDelete, withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths(rowsToInsert, withRowAnimation: .Fade)
        tableView.insertSections(sectionsToInsert, withRowAnimation: .Fade)
        tableView.deleteSections(sectionsToDelete, withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    // MARK: private funcs core data stuff
    private func getAgencys() -> [Agency]? {
        let request = NSFetchRequest.init(entityName: "Agency")

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
