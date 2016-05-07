//
//  LocationController.swift
//  TransitAlarm
//
//  Created by id on 5/2/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

protocol LocationControllerDelegate {
    func stopMonitoringRegion()
    func startMonitoringRegionFor(stop: Stop)
}

class LocationController: NSObject,
    LocationControllerDelegate,
    CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var mapDelegate: MapDelegate?
    
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
        print("\(unsafeAddressOf(locationManager)))")
    }
    
    func saveFavoriteFor(stop: Stop) {
        // save to NSUserDefaults
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!

        if !self.didCenterMap {
           // self.centerMapOnUser() // FIXME: send to mapdelegate
            self.didCenterMap  = !self.didCenterMap
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
        self.stop = stop
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

    // MARK: private location+map stuff
    // FIXME: refactor and move to Map Controller
    private func regionWithAnnotation() -> CLCircularRegion {
        let geoLocation = stop!.location2D
        let radius: CLLocationDistance!
        radius = 300
        let regionTitle = stop?.name
        let region = CLCircularRegion(center: geoLocation, radius: radius, identifier: regionTitle!)
        let overlay = MKCircle(centerCoordinate: geoLocation, radius: radius)
        self.mapDelegate?.addOverlay(overlay)
        return region
    }

    private func handleRegionEvent(region: CLRegion!) {
        // FIXME: get simulator warning: 
    // 2016-05-07 14:54:33.405 TransitAlarm[8625:34597312] Warning: Attempt to present <UIAlertController: 0x7fbbaa6b2880>  on <SWRevealViewController: 0x7fbba4864a00> which is already presenting <UIAlertController: 0x7fbbaa3e10f0>
        // 2016-05-07 14:54:38.461 TransitAlarm[8625:34597312] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fbbaa6b2880>)

        if UIApplication.sharedApplication().applicationState == .Active {
            showAlertWithSaveOption(region.identifier, message: "Your stop is approaching, would you like to save stop for future use? If you choose 'save' you will be prompted to login via Facebook so that you may save stops across multiple devices.")
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
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController!
        vc?.presentViewController(alert, animated: true, completion: nil)
    }

    private func showAlertWithSaveOption(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) in
            if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
//              self.saveFavoriteFor(self.stop!)
            } else {
//              self.facebookLogin()
            }
        }
        alert.addAction(action)
        alert.addAction(saveAction)
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController!
        stopMonitoringRegion()
        vc?.presentViewController(alert, animated: true, completion: nil)
    }
}
