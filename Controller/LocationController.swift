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
    var isMonitoring: Bool {get}
}

class LocationController: NSObject {
    let locationManager = CLLocationManager()
    var mapDelegate: MapDelegate?
    var alertDelegate: AlertDelegate?
    
    let favorites = [String]()
    var stop: Stop?

    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false
    var isMonitoring = false

    // FIXME: use something like a dispatch once to prevent multiple initialization
    static let sharedInstance = LocationController()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
        self.alertDelegate?.presentAlert(alert, completion:nil)
    }
}

// MARK: CLLocationManagerDelegate
extension LocationController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("\(locations)") // for seeing whats up in the background / asleep
        currentLocation = locations.first!
        if !self.didCenterMap {
            self.mapDelegate?.setCenterOnCoordinate(self.currentLocation.coordinate, animated: true) // for seeing whats up in the background / asleep
            self.didCenterMap  = !self.didCenterMap
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways {
            let (alert, completionHandler) = AlertCatalog.locationPermission()
            self.alertDelegate?.presentAlert(alert, completion: completionHandler)
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return false
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("\(error)")
    }
}


// MARK: LocationControllerDelegate
extension LocationController: LocationControllerDelegate {
    func stopMonitoringRegion() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        self.mapDelegate?.removeStopPin()
        self.isMonitoring = false

        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    func startMonitoringRegionFor(stop:Stop) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            let (alert, completion) = AlertCatalog.locationPermission()
            self.alertDelegate?.presentAlert(alert, completion: completion)
            return
        }

        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            let (alert, completion) = AlertCatalog.locationPermission()
            self.alertDelegate?.presentAlert(alert, completion: completion)
            return
        }

        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        if !appDelegate.notificationSettings {
            let (alert, completion) = AlertCatalog.notificationPermission()
            self.alertDelegate?.presentAlert(alert, completion: completion)
            return
        }

        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.stopMonitoringSignificantLocationChanges()
        }

        let (alert, completion) = AlertCatalog.stopSetAlert(stop)
        self.alertDelegate?.presentAlert(alert, completion: completion, timeout: Constants.alertTimeout)

        let notification = makeUILocalNotificationFor(stop)
        self.stop = stop
        self.mapDelegate?.addOverlay(GeoFence(stop: stop).overlay)
        self.mapDelegate?.drawStop(stop)
        self.mapDelegate?.setCenterOnCoordinate(stop.location2D, animated: true)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        self.isMonitoring = true
    }
}