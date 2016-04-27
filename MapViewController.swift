//
//  StopViewController.swift
//  TransitAlarm
//
//  Created by id on 4/19/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var stop: Stop?

    let dataService = DataService()
    let favorites = [String]()

    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var distanceLabelFeet: UILabel!
    @IBOutlet weak var distanceLabelMiles: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var didCenterMap = false

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        locationManager.delegate = self
        self.mapView.delegate = self
        locationManager.requestAlwaysAuthorization()

        self.stopNameLabel.text = stop?.name
        self.title = stop?.name

        regionWithAnnotation()
        dropStopPin()
    }

    override func viewDidAppear(animated: Bool) {
        startMonitoringGeotification()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        self.updateDistance()
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
        self.updateDistance()

        if !self.didCenterMap {
            centerMap()
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
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
        circleRenderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        return circleRenderer
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else {
            let pin = MKAnnotationView()
            pin.image = UIImage.init(named: "MapIcon")
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
        let region = regionWithAnnotation()
        locationManager.startMonitoringForRegion(region)
    }

    private func updateDistance() {
        let distanceFeet = stop?.location.distanceFromLocation(currentLocation).metersToFeet()
        let distanceMiles = stop?.location.distanceFromLocation(currentLocation).metersToMiles()

        self.distanceLabelMiles.text = String(format: "Miles Away: %.3f", distanceMiles!)
        self.distanceLabelFeet.text =  String(format: "Feet Away: %.0f", distanceFeet!)
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
