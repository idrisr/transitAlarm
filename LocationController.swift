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
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

protocol LocationControllerDelegate {
    func stopMonitoringRegion()
    func startMonitoringRegionFor(stop: Stop)
}

protocol StopFavoriteDelegate {
    func saveFavoriteFor(stop: Stop)
}

class LocationController: NSObject,
    LocationControllerDelegate,
    StopFavoriteDelegate,
    CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var mapView: MKMapView
    
    let dataService = DataService()
    let favorites = [String]()
    var stop: Stop?

    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func saveFavoriteFor(stop: Stop) {
        let transitStopName: Dictionary<String,String> = [
            "transitStop": stop.id!
        ]
        let firebaseSaveStop = DataService.dataService.REF_CURRENT_USER.childByAppendingPath("favorites")
        let firebaseSaveStopList = firebaseSaveStop.childByAutoId()
        firebaseSaveStopList.updateChildValues(transitStopName)
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
        self.removeGeoFenceOverlay()
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
        self.dropStopPin()
    }

    func removeGeoFenceOverlay() {
        for overlay in self.mapView.overlays {
            if overlay is MKCircle {
                self.mapView.removeOverlay(overlay)
            }
        }
        self.remoteStopPin()
    }

    // MARK: private location+map stuff
    private func dropStopPin() {
        let stopAnnotation = MKPointAnnotation()
        stopAnnotation.coordinate = stop!.location2D
        self.mapView.addAnnotation(stopAnnotation)
    }

    private func remoteStopPin() {
        for annotation in self.mapView.annotations {
            if annotation is MKPointAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
    }

    private func regionWithAnnotation() -> CLCircularRegion {
        let geoLocation = stop!.location2D
        let radius: CLLocationDistance!
        radius = 300
        let regionTitle = stop?.name
        let region = CLCircularRegion(center: geoLocation, radius: radius, identifier: regionTitle!)
        let overlay = MKCircle(centerCoordinate: geoLocation, radius: radius)
        mapView.addOverlay(overlay)
        return region
    }

    private func centerMapOnUser() {
        let distanceMeters: Double = 5000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, distanceMeters, distanceMeters)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    private func handleRegionEvent(region: CLRegion!) {
        print("Transit stop approaching!")
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
              self.saveFavoriteFor(self.stop!)
            } else {
              self.facebookLogin()
            }
        }
        alert.addAction(action)
        alert.addAction(saveAction)
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController!
        stopMonitoringRegion()
        vc?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func facebookLogin() {
        let ref = Firebase(url: "https://transit-alarm.firebaseio.com")
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                    if error != nil {
                            print("Login failed. \(error)")
                    } else {
                            print("Logged in! \(authData)")
                    }
            let user = ["provider": authData.provider!, "email":"email"]
            DataService.dataService.createFirebaseUser(authData.uid, user: user)
            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
            let transitStopName: Dictionary<String,String> = [
                "transitStop":self.stop!.name!
                ]
            let firebaseSaveStop = DataService.dataService.REF_CURRENT_USER.childByAppendingPath("favorites")
            let firebaseSaveStopList = firebaseSaveStop.childByAutoId()
            firebaseSaveStopList.updateChildValues(transitStopName)
                })
            }
        })
    }
}