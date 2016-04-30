//
//  OneBigViewController.swift
//  TransitAlarm
//
//  Created by id on 4/28/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import CoreData
import MapKit
import UIKit

class OneBigViewController: UIViewController,
                            CLLocationManagerDelegate,
                            MKMapViewDelegate,
                            UITableViewDataSource,
                            UITableViewDelegate {

    var stop: Stop?

    let dataService = DataService()
    let favorites = [String]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?


    // corresponds to which sections are opened
    var opened = [true, false, false]

    var agencys = [Agency]()
    var routes = [Route]()
    var stops = [Stop]()

    var sectionClosed = [Bool]()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var didCenterMap = false
    var dataSource: [[AnyObject]]?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false

        self.tableView.delegate = self
        self.tableView.dataSource = self

        moc = appDelegate.managedObjectContext
        locationManager.delegate = self
        self.mapView.delegate = self
        locationManager.requestAlwaysAuthorization()

        self.loadAgencys()
        self.loadRoutes()
        self.loadStops()

        var dataSource = [self.agencys, self.routes, self.stops]

//        regionWithAnnotation()
//        dropStopPin()
    }

    override func viewDidAppear(animated: Bool) {
        startMonitoringGeotification()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.mapView.addOverlay(self.stop!.route!.shapeLine)
//        self.mapView.addOverlays(self.stop!.route!.stopOverlays)
        locationManager.startUpdatingLocation()
        centerMapOnUser()
    }

    override func viewDidDisappear(animated: Bool) {
        stopMonitoringRegion()
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.opened[section] {
            switch section {
            case tableSection.Agency.rawValue:
                return self.agencys.count
            case tableSection.Route.rawValue:
                return self.routes.count
            case tableSection.Stop.rawValue:
                return self.stops.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case tableSection.Agency.rawValue:
            let reuseID = "agencyCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
            let agency = self.agencys[indexPath.row]
            cell.textLabel?.text = agency.name
            return cell

        case tableSection.Route.rawValue:
            let reuseID = "agencyCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
            let route = self.routes[indexPath.row]
            cell.textLabel?.text = route.long_name
            return cell

        case tableSection.Stop.rawValue:
            let reuseID = "agencyCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
            let stop = self.stops[indexPath.row]
            cell.textLabel?.text = stop.name
            return cell
        default:
            let reuseID = "agencyCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
            return cell
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }

    func tableView(tableView: UITableView, titleForHeaderInSection: Int) -> String? {
        return tableSection(rawValue: titleForHeaderInSection)!.headerTitle()
    }


    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Selected: \(indexPath.section) \(indexPath.row)")

        // if pick in section n
        switch indexPath.section {
        case tableSection.Agency.rawValue:
            self.opened[indexPath.section + 1] = !self.opened[indexPath.section + 1]

        case tableSection.Route.rawValue:
            self.opened[indexPath.section + 1] = !self.opened[indexPath.section + 1]

        default:
            print("do nothing")
        }
        self.tableView.reloadData()

        // open up section n+1
    }


    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!

        if !self.didCenterMap {
            self.centerMapOnUser()
            self.didCenterMap  = !self.didCenterMap
        }
    }

    func stopMonitoringRegion() {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == region.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEventExit(region)
        }
    }

    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = self.stop?.route?.mapColor
            renderer.lineWidth = 2.0
            return renderer
        } else if overlay is StopMapOverlay {
            let stopImage = UIImage(named:"StopIcon")
            return StopOverlayRenderer(overlay: overlay, overlayImage: stopImage!)
        } else {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            return circleRenderer
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else if annotation.title! == self.stop!.name {
            let pin = MKAnnotationView()
            pin.image = UIImage.init(named: "MapIcon")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pin
        } else {
            let pin = MKAnnotationView()
            pin.image = UIImage.init(named: "StopIcon")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pin
        }
    }

    // MARK: private methods
    private func regionWithAnnotation() -> CLCircularRegion {
        let geoLocation = stop!.location2D
        let radius: CLLocationDistance!
        radius = 500
        let regionTitle = stop?.name
        let region = CLCircularRegion(center: geoLocation, radius: radius, identifier: regionTitle!)
        let overlay = MKCircle(centerCoordinate: geoLocation, radius: radius)
        mapView.addOverlay(overlay)
        return region
    }

    private func startMonitoringGeotification() {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showAlert("Error", message: "Geofencing not supported on device.")
            return
        }
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
           showAlert("Error", message: "Location always on not enabled, transit stop notification will not be sent")
        }
//        let region = regionWithAnnotation()
//        locationManager.startMonitoringForRegion(region)
    }

    private func centerMapOnUser() {
        let distanceMeters: Double = 5000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, distanceMeters, distanceMeters)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    private func centerMap() {
        let latitudeDistance = abs(self.stop!.getLatitude() - self.currentLocation.coordinate.latitude).degreesToMeters()
        let longitudeDistance = abs(self.stop!.getLongitude() - self.currentLocation.coordinate.longitude).degreesToMeters()

        let averageLatitude = (self.stop!.getLatitude() + self.currentLocation.coordinate.latitude) / 2
        let averageLongitude = (self.stop!.getLongitude() + self.currentLocation.coordinate.longitude) / 2

        let averageLocation = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(averageLocation, latitudeDistance * 1.1, longitudeDistance * 1.1)

        self.mapView.setRegion(coordinateRegion, animated: false)
    }

    private func getStopCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.stop!.getLatitude(), self.stop!.getLongitude())
    }

    private func dropStopPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.stop!.location2D
        annotation.title = self.stop!.name
        self.mapView.addAnnotation(annotation)
    }

    private func addStopOverlays() {
        self.mapView.addOverlays(self.stop!.route!.stopOverlays)
    }

    private func addStopAnnotations() {
        self.mapView.addAnnotations(self.stop!.route!.stopAnnotations)
    }

    private func handleRegionEvent(region: CLRegion!) {
        print("Transit stop approaching!")
        if UIApplication.sharedApplication().applicationState == .Active {
            showAlertWithSaveOption(region.identifier, message: "Your stop is approaching, would you like to save stop for future use?")
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = "Approaching \(region.identifier)"
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }

    private func handleRegionEventExit(region: CLRegion!) {
        print("You have missed your stop.")
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    private func showAlertWithSaveOption(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) in
            let transitStopName: Dictionary<String,String> = [
                "transitStop":self.stop!.name!
            ]
//            let saveStop = DataService.dataService.REF_CURRENT_USER
            let firebaseSaveStop = DataService.dataService.REF_CURRENT_USER.childByAppendingPath("favorites")
            let firebaseSaveStopList = firebaseSaveStop.childByAutoId()
            firebaseSaveStopList.updateChildValues(transitStopName)
//            self.dataService.getTransitStops()
        }
        alert.addAction(action)
        alert.addAction(saveAction)
        locationManager.stopUpdatingLocation()
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: private funcs core data stuff
    private func loadAgencys() {
        let request = NSFetchRequest.init(entityName: "Agency")

        do {
            let result = try self.moc!.executeFetchRequest(request)
            self.agencys = result as! [Agency]
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    // MARK: private funcs core data stuff
    private func loadRoutes() {
        let request = NSFetchRequest.init(entityName: "Route")

        do {
            let result = try self.moc!.executeFetchRequest(request)
            self.routes = result as! [Route]
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    // MARK: private funcs core data stuff
    private func loadStops() {
        let request = NSFetchRequest.init(entityName: "Stop")

        do {
            let result = try self.moc!.executeFetchRequest(request)
            stops = result as! [Stop]
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}