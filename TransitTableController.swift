//
//  StopPickerTableDataSource.swift
//  TransitAlarm
//
//  Created by id on 4/30/16.
//  Copyright © 2016 id. All rights reserved.
//

import MapKit
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
                              MKMapViewDelegate,
                              TransitDataStopUpdate,
                              UIGestureRecognizerDelegate,
                              UITableViewDataSource,
                              UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?

    var agencys = [Agency]()
    var routes = [Route]()
    var stops = [Stop]()
    var sections = ["Agency"]
    var mapView: MKMapView?
    var locationDelegate: LocationControllerDelegate?
    var tableSizeDelegate: TableSizeDelegate?

    override init() {
        super.init()
        moc = appDelegate.managedObjectContext
        self.agencys = self.getAgencys()!
    }

    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is RouteLine {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = (overlay as! RouteLine).color
            renderer.lineWidth = 8.0
            return renderer
        } else if overlay is StopMapOverlay {
            let stopOverlay = overlay as! StopMapOverlay
            return StopOverlayRenderer(overlay: stopOverlay, color: stopOverlay.color)
        } else {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            return circleRenderer
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if annotation.title! == self.stops[0].name {
            let pin = MKAnnotationView()
            pin.image = UIImage.init(named: "MapIcon")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pin
        } else {
            return nil
        }
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

                // fix me into an enum, please
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

        // this chunk can probably be reduced to one line of code
        switch tableSection(rawValue: indexPath.section)! {
            case .Agency:
                if self.agencys.count == 1 {
                    tableUpdates = agencyOneToMany(indexPath)
                } else {
                    tableUpdates = agencyManyToOne(indexPath)
                }

            case .Route:
                if self.routes.count == 1 {
                    tableUpdates = routeOneToMany(indexPath)
                } else {
                    tableUpdates = routeManyToOne(indexPath)
                }

            case .Stop:
                if self.stops.count == 1 {
                    tableUpdates = stopOneToMany(indexPath)
                } else {
                    tableUpdates = stopManyToOne(indexPath)
                }
            }

        self.updateTableWith(tableUpdates, tableView: tableView)
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeights.Header.height()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableHeights.Row.height()
    }

    // MARK: TransitDataStopUpdate
    func setAlertFor(stop: Stop, tableView: UITableView) {
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

        tableUpdates.sectionsToInsert = NSIndexSet(indexesInRange: NSMakeRange(tableView.numberOfSections, tableSection.allValues.count - 1))

        self.sections = ["Agency", "Routes", "Stops"]
        self.locationDelegate?.startMonitoringRegionFor(self.stops.first!)
        self.updateTableWith(tableUpdates, tableView: tableView)
    }

    // MARK: TransitTableDelegate

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
        self.removeRouteFromMap()
        self.locationDelegate?.stopMonitoringRegion()

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

        // put route on to map
        self.drawRouteOnMap()
        return tableUpdates
    }

    private func routeOneToMany(indexPath: NSIndexPath) -> TableUpdates {
        var tableUpdates = TableUpdates()

        // take route off of map
        self.removeRouteFromMap()
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

    private func drawRouteOnMap() {
        self.mapView?.addOverlays( self.routes.map{ ($0.shapeLine) } )
        self.addStopOverlays()
    }

    private func removeRouteFromMap() {
        for overlay in self.mapView!.overlays {
            if overlay is RouteLine  {
                self.mapView?.removeOverlay(overlay)
            }
        }
        self.removeStopOverlays()
        self.removeStopAnnotations()
    }

    private func addStopOverlays() {
        let route = self.routes.first
        self.mapView!.addOverlays(route!.stopOverlays)
    }

    private func removeStopOverlays() {
        for overlay in self.mapView!.overlays {
            if overlay is StopMapOverlay {
                self.mapView?.removeOverlay(overlay)
            }
        }
    }

    private func removeStopAnnotations() {
        for annotation in self.mapView!.annotations {
            if annotation is StopAnnotation {
                self.mapView?.removeAnnotation(annotation)
            }
        }
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
