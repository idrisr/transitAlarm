//
//  OneBigViewController.swift
//  TransitAlarm
//
//  Created by id on 4/28/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit


class MainViewController: UIViewController,
                            CLLocationManagerDelegate,
                            MKMapViewDelegate {

    @IBOutlet weak var mapviewHeightConstraint: NSLayoutConstraint!

    let dataService = DataService()
    let favorites = [String]()
    var stop: Stop?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false
    var tableDataSource = TableDataSourceDelegate()

    var maxMapHeight: CGFloat?
    var minMapHeight: CGFloat?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.delegate = self.tableDataSource

        self.tableView.delegate = self.tableDataSource
        self.tableView.dataSource = self.tableDataSource
        self.tableDataSource.mapView = self.mapView

        self.minMapHeight = 50
        self.maxMapHeight = UIScreen.mainScreen().bounds.size.height - minMapHeight!

//        regionWithAnnotation()
//        dropStopPin()
    }

    @IBAction func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began, .Changed:
                // get change from last translation
                let totalTranslation = gesture.translationInView(gesture.view?.superview)
                let newTranslation = totalTranslation.y - self.prevTranslation
                let newMapHeight = self.mapView.frame.height + newTranslation

                if newMapHeight > self.minMapHeight && newMapHeight < self.maxMapHeight {
                    self.mapviewHeightConstraint.constant += newTranslation
                    self.prevTranslation = totalTranslation.y
                }

            case .Cancelled, .Ended:
                self.prevTranslation = 0

            case .Possible, .Failed:
                break
        }
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

//    // MARK: private methods user location stuff
//    private func drawRoutes() {
//        for route in self.routes {
//            self.mapView.addOverlay(route.shapeLine)
//        }
//    }

    // MARK: private methods map stuff
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

}
