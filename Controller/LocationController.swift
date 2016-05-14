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

// FIXME: Simulator warning:
// Trying to start MapKit location updates without prompting for location authorization. Must call -[CLLocationManager requestWhenInUseAuthorization] or -[CLLocationManager requestAlwaysAuthorization] first.

// FIXME: uibackgroundmodes core location
// FIXME: significant location changes

class LocationController: NSObject {
    let locationManager = CLLocationManager()
    var mapDelegate: MapDelegate?
    var alertDelegate: AlertDelegate?
    
    let favorites = [String]()
    var stop: Stop?

    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false

    // FIXME: use something like a dispatch once to prevent multiple initialization
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


    private func makeUILocalNotificationFor(stop: Stop) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.alertBody = "Approaching \(stop.name!)"
        notification.alertTitle = "Prepare to Exit!"
        notification.soundName = "alarm.wav"
        let geoFence = GeoFence(stop: stop)
        notification.region = geoFence.region
        notification.regionTriggersOnce = true
        return notification
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.alertDelegate?.presentAlert(alert, completionHandler: {})
    }
}

// MARK: CLLocationManagerDelegate
extension LocationController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        if !self.didCenterMap {
            self.mapDelegate?.setCenterOnCoordinate(self.currentLocation.coordinate, animated: true)
            self.didCenterMap  = !self.didCenterMap
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // FIXME: handle me
    }

    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return false
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // FIXME: do something
    }
}


// MARK: LocationControllerDelegate
extension LocationController: LocationControllerDelegate {
    func stopMonitoringRegion() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        self.mapDelegate?.removeStopPin()
    }

    func startMonitoringRegionFor(stop:Stop) {
        // can also create a UILocationNotification that triggers on region
        // https://developer.apple.com/library/ios/documentation/iPhone/Reference/UILocalNotification_Class/index.html#//apple_ref/occ/instp/UILocalNotification/region

        let notification = makeUILocalNotificationFor(stop)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

        self.stop = stop
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showAlert("Error", message: "Geofencing not supported on device.")
            return
        } else if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
           // FIXME, improve this message
           // Deep link to settings
            // FIXME: use alert delegate
           showAlert("Error", message: "Location always on not enabled, transit stop notification can not be sent")
           return
        }
        self.mapDelegate?.addOverlay(GeoFence(stop: stop).overlay)
    }
}