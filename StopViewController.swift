//
//  StopViewController.swift
//  TransitAlarm
//
//  Created by id on 4/19/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreLocation

class StopViewController: UIViewController, CLLocationManagerDelegate {
    var stop: Stop?

    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var distanceLabelFeet: UILabel!
    @IBOutlet weak var distanceLabelMiles: UILabel!

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.stopNameLabel.text = stop?.stop_name
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

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        self.updateDistance()
    }

    private func updateDistance() {
        let distanceFeet = stop?.location.distanceFromLocation(currentLocation).metersToFeet()
        let distanceMiles = stop?.location.distanceFromLocation(currentLocation).metersToMiles()

        self.distanceLabelMiles.text = String(format: "Miles Away: %.3f", distanceMiles!)
        self.distanceLabelFeet.text =  String(format: "Feet Away: %.0f", distanceFeet!)
    }
}
