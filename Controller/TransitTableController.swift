//
//  StopPickerTableDataSource.swift
//  TransitAlarm
//
//  Created by id on 4/30/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

extension UIColor {
    class func CTAColor() -> UIColor {
        return UIColor(colorLiteralRed: 60/256, green: 117/256, blue: 194/256, alpha: 1)
    }

    class func metraColor() -> UIColor {
        return UIColor(colorLiteralRed: 50/256, green: 80/256, blue: 159/256, alpha: 1)
    }
}

protocol TransitDataStopUpdate {
    func setAlertFor(stop: Stop, tableView: UITableView)
}


struct TableUpdates {
    // holds arrays for which rows and sections to insert / delete
    var rowsToDelete     = [NSIndexPath]()
    var rowsToInsert     = [NSIndexPath]()
    var sectionsToDelete = NSIndexSet()
    var sectionsToInsert = NSIndexSet()
}

class TransitTableController: NSObject,
                              TransitDataStopUpdate,
                              UIGestureRecognizerDelegate,
                              UITableViewDataSource,
                              UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?

    var stopAlertPopupDelegate :StopAlertPopupDelegate?
    var agencys = [Agency]()
    var routes = [Route]()
    var stops = [Stop]()
    var sections = ["Agency"]
    var locationDelegate: LocationControllerDelegate?
    var tableSizeDelegate: TableSizeDelegate?
    var mapDelegate: MapDelegate?

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
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) as! AgencyTableViewCell
                var color: UIColor

                // FIXME: into an enum, please
                var imageName: String
                switch agency.name! {
                    case "CTA Bus":
                        imageName = "cta_bus_white"
                        cell.backgroundColor = UIColor(colorLiteralRed: 60/256, green: 117/256, blue: 194/256, alpha: 1)
                        color = UIColor.CTAColor()

                    case "Metra":
                        imageName = "cta_train_white"
                        color = UIColor.metraColor()

                    case "CTA Train":
                        imageName = "cta_train_white"
                        color = UIColor.CTAColor()

                    default:
                        imageName = ""
                        color = UIColor.whiteColor()
                }

                cell.iconImageView!.image = UIImage(named: imageName)
                cell.nameLabel.text = agency.name
                cell.backgroundColor = color
                return cell

            case .Route:
                let reuseID = "routeCell"
                let route = self.routes[indexPath.row]

                // Q: cant we init the cell with the route and get the prepared cell back?
                // A: yes. MVVM?

                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) as! RouteTableViewCell
                cell.backgroundColor = route.mapColor

                cell.idLabel.text = route.id!
                cell.nameLabel.text = route.long_name!

                cell.idLabel.textColor = route.mapTextColor
                cell.nameLabel.textColor = route.mapTextColor
                return cell

            case .Stop:
                let reuseID = "stopCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
                let stop = self.stops[indexPath.row]
                let route = stop.route!

                cell.backgroundColor = route.mapColor
                cell.textLabel?.textColor = route.mapTextColor
                cell.textLabel?.text = route.long_name
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
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var tableUpdates = TableUpdates()
        var didSetStop = false

        // FIXME: what a mess. mapping. table data updates. zooming. too much. state pattern?
        // this chunk can probably be reduced to one line of code
        switch tableSection(rawValue: indexPath.section)! {
            case .Agency:
                if self.agencys.count == 1 {
                    self.locationDelegate?.stopMonitoringRegion()
                    tableUpdates = agencyOneToMany(indexPath)
                    self.mapDelegate?.clearMap()
                } else {
                    tableUpdates = agencyManyToOne(indexPath)
                }

            case .Route:
                if self.routes.count == 1 {
                    tableUpdates = routeOneToMany(indexPath)
                    self.mapDelegate?.clearMap()
                } else {
                    tableUpdates = routeManyToOne(indexPath)
                    self.mapDelegate?.drawRoute(self.routes.first! as Route)
                    // center on route center
                    self.mapDelegate?.setCenterOnCoordinate(self.routes.first!.routeCenter, animated: true)
                }

            case .Stop:
                if self.stops.count == 1 {
                    tableUpdates = stopOneToMany(indexPath)
                    self.mapDelegate?.removeStopPin()
                } else {
                    tableUpdates = stopManyToOne(indexPath)
                    self.mapDelegate?.drawStop(self.stops.first!)
                    self.mapDelegate?.setCenterOnCoordinate(self.stops.first!.location2D, animated: true)

                    // should call the same method the delegates are to set the stop
                    // UG.LY.
                    didSetStop = true
                    self.updateTableWith(tableUpdates, tableView: tableView)
                    let stop = self.stops.first!
                    self.setAlertFor(stop, tableView: tableView)
                }
            }

        if !didSetStop {
            self.updateTableWith(tableUpdates, tableView: tableView)
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeights.Header.height()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableHeights.Row.height()
    }

    // MARK: TransitDataStopUpdate
    func setAlertFor(stop: Stop, tableView: UITableView) {
        self.stopAlertPopupDelegate?.showAlert(stop)

        var tableUpdates = TableUpdates()

        // remove all agencys
        for i in 0..<self.agencys.count {
            tableUpdates.rowsToDelete.append(NSIndexPath(forItem: i, inSection: tableSection.Agency.rawValue))
        }
        // remove all routes
        for i in 0..<self.routes.count {
            tableUpdates.rowsToDelete.append(NSIndexPath(forItem: i, inSection: tableSection.Route.rawValue))
        }
        // remove all stops
        for i in 0..<self.stops.count {
            tableUpdates.rowsToDelete.append(NSIndexPath(forItem: i, inSection: tableSection.Stop.rawValue))
        }

        self.stops = [stop]
        self.routes = [stop.route!]
        self.agencys = [stop.route!.agency!]

        // add new agency
        tableUpdates.rowsToInsert.append(NSIndexPath(forItem: 0, inSection: tableSection.Agency.rawValue))

        // add new route
        tableUpdates.rowsToInsert.append(NSIndexPath(forItem: 0, inSection: tableSection.Route.rawValue))

        // add new stop
        tableUpdates.rowsToInsert.append(NSIndexPath(forItem: 0, inSection: tableSection.Stop.rawValue))

        let additionalSections = tableSection.allValues.count - tableView.numberOfSections
        tableUpdates.sectionsToInsert = NSIndexSet(indexesInRange: NSMakeRange(tableView.numberOfSections, additionalSections))

        self.sections = ["Agency", "Routes", "Stops"]
        self.locationDelegate?.startMonitoringRegionFor(self.stops.first!)
        self.updateTableWith(tableUpdates, tableView: tableView)
    }


    // MARK: private func-y stuff
    private func updateTableWith(tableUpdates: TableUpdates, tableView: UITableView) {
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(tableUpdates.rowsToInsert, withRowAnimation: .Fade)
        tableView.deleteRowsAtIndexPaths(tableUpdates.rowsToDelete, withRowAnimation: .Fade)
        tableView.insertSections(tableUpdates.sectionsToInsert, withRowAnimation: .Fade)
        tableView.deleteSections(tableUpdates.sectionsToDelete, withRowAnimation: .Fade)
        tableView.endUpdates()
        self.tableSizeDelegate?.adjustTableSize()
    }

    private func agencyOneToMany(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        // take route off of map

        let existingAgency = self.agencys.first
        self.agencys = self.getAgencys()!
        self.agencys.sortInPlace({$0.name < $1.name})

        tableUpdates.sectionsToDelete = NSIndexSet(indexesInRange: NSMakeRange(1, self.sections.count - 1))
        self.sections = ["Agency"]

        for i in 0..<agencys.count {
            if agencys[i] != existingAgency {
                tableUpdates.rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
            }
        }
        return tableUpdates
    }

    private func agencyManyToOne(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        self.sections = ["Agency", "Routes"]
        let agency = self.agencys[indexPath.row]
        self.routes = agency.routes?.allObjects as! [Route]
        tableUpdates.sectionsToInsert = NSIndexSet(index: 1)

        // remove unselected agencies
        var agencysToRemove = [Agency]()
        for i in 0..<self.agencys.count {
            if i != indexPath.row {
                tableUpdates.rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                agencysToRemove.append(self.agencys[i])
            }
        }

        // brittle. sort routes depends on only agency present
        self.agencys.removeObjectsInArray(agencysToRemove)
        self.sortRoutes()

        return tableUpdates
    }

    private func routeManyToOne(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        self.sections = ["Agency", "Routes", "Stops"]
        let route = self.routes[indexPath.row]
        self.stops = route.stops?.allObjects as! [Stop]
        self.stops.sortInPlace({Int($0.sequence!) < Int($1.sequence!)})
        tableUpdates.sectionsToInsert = NSIndexSet(index: 2)

        // remove unselected agencies
        var routesToRemove = [Route]()
        for i in 0..<self.routes.count {
            if i != indexPath.row {
                tableUpdates.rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                routesToRemove.append(self.routes[i])
            }
        }
        self.routes.removeObjectsInArray(routesToRemove)

        return tableUpdates
    }

    private func routeOneToMany(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        // take route off of map
        self.mapDelegate?.clearMap()
        self.locationDelegate?.stopMonitoringRegion()

        self.sections = ["Agency", "Routes"]
        let existingRoute = self.routes.first
        self.routes = self.agencys.first?.routes?.allObjects as! [Route]
        self.sortRoutes()

        tableUpdates.sectionsToDelete = NSIndexSet(index: 2) // use enum instead of magic number

        for i in 0..<self.routes.count {
            if routes[i] != existingRoute {
                tableUpdates.rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
            }
        }
        return tableUpdates
    }

    private func sortRoutes() {
        let agency = self.agencys.first

        // whats the better, more functional swifty way?
        // stringly typed. bad
        switch agency!.name! {
            case "CTA Bus":
                self.routes.sortInPlace({$0.idNumeric! < $1.idNumeric! })

            case "CTA Train":
                self.routes.sortInPlace({$0.id < $1.id})

            case "Metra":
                self.routes.sortInPlace({$0.id < $1.id})

            default:
                break
        }
    }

    private func stopOneToMany(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        // stop monitoring region
        self.locationDelegate?.stopMonitoringRegion()

        self.sections = ["Agency", "Routes", "Stops"]
        let existingStop = self.stops.first
        self.stops = self.routes.first?.stops?.allObjects as! [Stop]
        self.stops.sortInPlace({Int($0.sequence!) < Int($1.sequence!)})

        for i in 0..<self.stops.count {
            if stops[i] != existingStop {
                tableUpdates.rowsToInsert.append(NSIndexPath(forItem: i, inSection: indexPath.section))
            }
        }
        return tableUpdates
    }

    private func stopManyToOne(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        // from many to one stops
        self.sections = ["Agency", "Routes", "Stops"]
        // remove unselected agencies
        var stopsToRemove = [Stop]()
        for i in 0..<self.stops.count {
            if i != indexPath.row {
                tableUpdates.rowsToDelete.append(NSIndexPath(forRow: i, inSection: indexPath.section))
                stopsToRemove.append(self.stops[i])
            }
        }
        self.stops.removeObjectsInArray(stopsToRemove)

        // start monitoring region
        self.locationDelegate?.startMonitoringRegionFor(self.stops.first!)

        return tableUpdates
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
