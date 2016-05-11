//
//  LocationController.swift
//  TransitAlarm
//
//  Created by id on 5/2/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationControllerDelegate {
    func stopMonitoringRegion()
    func startMonitoringRegionFor(stop: Stop)
}

// FIXME:
// Simulator warning: 
// Trying to start MapKit location updates without prompting for location authorization. Must call -[CLLocationManager requestWhenInUseAuthorization] or -[CLLocationManager requestAlwaysAuthorization] first.

class LocationController: NSObject,
    LocationControllerDelegate,
    CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var mapDelegate: MapDelegate?
    var alertDelegate: AlertDelegate?
    
    let favorites = [String]()
    var stop: Stop?

    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false

    static let sharedInstance = LocationController()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func saveFavoriteFor(stop: Stop) {
        // save to NSUserDefaults
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        if !self.didCenterMap {
            self.mapDelegate?.setCenterOnCoordinate(self.currentLocation.coordinate, animated: true)
            self.didCenterMap  = !self.didCenterMap
        }
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
            stopMonitoringRegion()
        }
    }

    // MARK: LocationControllerDelegate
    func stopMonitoringRegion() {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == region.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
        self.mapDelegate?.removeStopPin()
    }

    func startMonitoringRegionFor(stop:Stop) {
        // can also create a UILocationNotification that triggers on region
        // https://developer.apple.com/library/ios/documentation/iPhone/Reference/UILocalNotification_Class/index.html#//apple_ref/occ/instp/UILocalNotification/region

        self.stop = stop
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showAlert("Error", message: "Geofencing not supported on device.")
            return
        }
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
           // FIXME, improve this message
           // Deep link to settings
           showAlert("Error", message: "Location always on not enabled, transit stop notification can not be sent")
           return
        }

        let geoFence = GeoFence(stop: stop)
        locationManager.startMonitoringForRegion(geoFence.region)
        self.mapDelegate?.addOverlay(geoFence.overlay)
    }

    // MARK: private location+map stuff
    private func handleRegionEvent(region: CLRegion!) {
        let notification = UILocalNotification()
        notification.alertBody = "Approaching \(region.identifier)"
        notification.soundName = "Default";
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.alertDelegate?.presentAlert(alert, completionHandler: {})
    }
}