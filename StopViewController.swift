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
    var stop: Stop?

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

        self.stopNameLabel.text = stop?.stop_name
        self.title = stop?.stop_name

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
}
