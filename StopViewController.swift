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

class StopViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var stop: Stop_?

    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var distanceLabelFeet: UILabel!
    @IBOutlet weak var distanceLabelMiles: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var didCenterMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        locationManager.delegate = self
        self.mapView.delegate = self
        locationManager.requestAlwaysAuthorization()

        self.stopNameLabel.text = stop?.stop_name
        self.title = stop?.stop_name

        regionWithAnnotation()
        startMonitoringGeotification()
        dropStopPin()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        self.updateDistance()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    override func viewDidDisappear(animated: Bool) {
        stopMonitoringRegion()
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
    
    func regionWithAnnotation() -> CLCircularRegion {
        let geoLocation = CLLocationCoordinate2DMake(self.stop!.location.coordinate.latitude, self.stop!.location.coordinate.longitude)
        let radius: CLLocationDistance!
        radius = 500
        let regionTitle = stop?.stop_name
        let region = CLCircularRegion(center: geoLocation, radius: radius, identifier: regionTitle!)
        let overlay = MKCircle(centerCoordinate: geoLocation, radius: radius)
        mapView.addOverlay(overlay)
        return region
    }
    
    func startMonitoringGeotification() {
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

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
        circleRenderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        return circleRenderer
    }

    // MARK: MKMapViewDelegate
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

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        self.updateDistance()

        if !self.didCenterMap {
            centerMap()
            self.didCenterMap  = !self.didCenterMap
        }
    }

    // MARK: private methods
    private func updateDistance() {
        let distanceFeet = stop?.location.distanceFromLocation(currentLocation).metersToFeet()
        let distanceMiles = stop?.location.distanceFromLocation(currentLocation).metersToMiles()

        self.distanceLabelMiles.text = String(format: "Miles Away: %.3f", distanceMiles!)
        self.distanceLabelFeet.text =  String(format: "Feet Away: %.0f", distanceFeet!)
    }

    private func centerMap() {
        let latitudeDistance = abs(self.stop!.location.coordinate.latitude - self.currentLocation.coordinate.latitude).degreesToMeters()
        let longitudeDistance = abs(self.stop!.location.coordinate.longitude - self.currentLocation.coordinate.longitude).degreesToMeters()


        let averageLatitude = (self.stop!.location.coordinate.latitude + self.currentLocation.coordinate.latitude) / 2
        let averageLongitude = (self.stop!.location.coordinate.longitude + self.currentLocation.coordinate.longitude) / 2

        let averageLocation = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(averageLocation, latitudeDistance * 1.1, longitudeDistance * 1.1)

        self.mapView.setRegion(coordinateRegion, animated: false)
    }

    private func getStopCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.stop!.location.coordinate.latitude, self.stop!.location.coordinate.longitude)
    }

    private func dropStopPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = getStopCoordinate2D()
        annotation.title = self.stop?.stop_name
        self.mapView.addAnnotation(annotation)
    }
    
    func handleRegionEvent(region: CLRegion!) {
        print("Transit stop approaching!")
        if UIApplication.sharedApplication().applicationState == .Active {
              showAlert("Transit Stop Approachig", message: region.identifier)
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = "Approaching \(region.identifier)"
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    func handleRegionEventExit(region: CLRegion!) {
        print("You have missed your stop.")
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
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
 
}
