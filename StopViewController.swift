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

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true

        self.stopNameLabel.text = stop?.stop_name
        self.title = stop?.stop_name

        centerMap()
        dropStopPin()
        dropUserLocationPin()
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
        if annotation.title! != stop?.stop_name {
            let pin = MKPinAnnotationView()
            return pin
        } else {
            let pin = MKAnnotationView()
            pin.image = UIImage.init(named: "bikeImage")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pin
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        self.updateDistance()
    }

    // MARK: private methods
    private func updateDistance() {
        let distanceFeet = stop?.location.distanceFromLocation(currentLocation).metersToFeet()
        let distanceMiles = stop?.location.distanceFromLocation(currentLocation).metersToMiles()

        self.distanceLabelMiles.text = String(format: "Miles Away: %.3f", distanceMiles!)
        self.distanceLabelFeet.text =  String(format: "Feet Away: %.0f", distanceFeet!)
    }

    private func centerMap() {
        let stopLocation = getStopCoordinate2D()
        self.mapView.setRegion(MKCoordinateRegionMake(stopLocation, MKCoordinateSpanMake(0.05, 0.05)), animated: true)
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

    private func dropUserLocationPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        self.mapView.addAnnotation(annotation)
    }
}
