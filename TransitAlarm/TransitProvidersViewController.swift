//
//  RouteViewController.swift
//  TransitAlarm
//
//  Created by id on 4/18/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreLocation

class TransitProvidersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var transitProviders = [String]()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        transitProviders = ["CTA Train"] // enum?
        self.askForUserLocationPermission()
    }

    func askForUserLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transitProviders.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "transitProviderCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        cell.textLabel!.text = self.transitProviders[indexPath.row]
        return cell
    }
}