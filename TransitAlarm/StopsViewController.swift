//
//  StopViewController.swift
//  TransitAlarm
//
//  Created by id on 4/18/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire
import CoreLocation

extension Double {
    func metersToMiles() -> Double {
        return self * 0.000621371
    }

    func metersToFeet() -> Double {
        return self * 3.28084
    }

    func degreesToMeters() -> Double {
        // https://en.wikipedia.org/wiki/Decimal_degrees#precision
        return self * 111.32 * 1000
    }
}

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {

    let _apiURL = "https://data.cityofchicago.org/api/views/8pix-ypme/rows.xml?accessType=DOWNLOAD"
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var transitProvider: String?
    var stops =  [[Stop]]()
    var filteredStops = [[Stop]]()
    var searchBarIsSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "CTA Train Stops"
        self.searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done

        // just have one location manager for whole app and set its delegate as we move through vcs
        locationManager.delegate = self

        downloadCTATrainData()
        // get rid of this stringly typed shit

        // init array or array with blank arrays
        for _ in 0..<CTATrainLine.allValues.count {
            self.stops.append([Stop]())
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first!
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarIsSearching {
            return self.filteredStops[section].count
        }
        return self.stops[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "stopsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let stop: Stop!
        
        if searchBarIsSearching {
            stop = filteredStops[indexPath.section][indexPath.row]
        } else {
            stop = stops[indexPath.section][indexPath.row]
        }
        
        cell.textLabel!.text = stop.stop_name
        let distanceInMiles = stop.location.distanceFromLocation(currentLocation).metersToMiles()
        cell.detailTextLabel!.text = String(format: "Miles Away: %.3f", distanceInMiles)
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.stops.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CTATrainLine(rawValue: section)?.headerName()
    }
    
//  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//      if  searchBar.text == nil || searchBar.text == "" {
//           searchBarIsSearching = false
//           tableView.reloadData()
//           view.endEditing(true)
//        } else {
//            searchBarIsSearching = true
//            let lower = searchBar.text!.lowercaseString
//            filteredStops = stops[0].filter({$0.stop_name!.rangeOfString(lower) != nil})
//            tableView.reloadData()
//        }
//    }

    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = CTATrainLine(rawValue: section)!.color()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        let stop = self.stops[indexPath!.section][indexPath!.row]

        let destinationVC = segue.destinationViewController as! StopViewController
        destinationVC.stop = stop
        self.locationManager.stopUpdatingLocation()
    }

    private func downloadCTATrainData() {
        let url = NSURL(string: self._apiURL)!
        Alamofire.request(.GET, url).responseString { response in
            let result = response.result
            let xml = SWXMLHash.parse(result.value!)
            var tmp = [Stop]()
            for stopXML in xml["response"]["row"]["row"] {
                let stop = Stop(xmlData: stopXML)
                tmp.append(stop)
            }

            // array of array for stops
            for stop in tmp {
                for trainLine in CTATrainLine.allValues {
                    if stop.lines.contains(trainLine) {
                        self.stops[trainLine.rawValue].append(stop)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}
