//
//  OneBigViewController.swift
//  TransitAlarm
//
//  Created by id on 4/28/16.
//  Copyright © 2016 id. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

protocol StopDelegate {
    func setAlarmForStop(stop: Stop)
}

class MainViewController: UIViewController, StopDelegate, TableSizeUpdateDelegate {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    let dataService = DataService()
    var stop: Stop?

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var openFavoritesButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationController: LocationController?
    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false
    var transitTable = TransitTableController()
    var stopUpdateDelegate: TransitDataStopUpdate?

    var maxMapHeight: CGFloat?
    var minMapHeight: CGFloat?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationController = LocationController(mapView: mapView)
        self.locationController!.mapView = self.mapView

        self.setDelegates()

        revealViewController().rearViewRevealWidth = 300
        revealViewController().rightViewRevealWidth = 300

        openFavoritesButton.target = self.revealViewController()
        openFavoritesButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        searchButton.target = self.revealViewController()
        searchButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))

        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.delegate = self.transitTable

        self.tableView.delegate = self.transitTable
        self.tableView.dataSource = self.transitTable
        self.transitTable.mapView = self.mapView
        self.transitTable.locationDelegate = locationController
        self.stopUpdateDelegate = self.transitTable

        self.minMapHeight = 50
        self.maxMapHeight = UIScreen.mainScreen().bounds.size.height - minMapHeight!
    }

    // MARK: StopDelegate
    func setAlarmForStop(stop: Stop) {
        self.stopUpdateDelegate!.setAlertFor(stop, tableView: self.tableView)
    }

    // MARK: IBActions
    @IBAction func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began, .Changed:
                // if tableview required height totally displayed, dont allow movement

                // get change from last translation
                let totalTranslation = gesture.translationInView(gesture.view?.superview)
                let newTranslation = totalTranslation.y - self.prevTranslation
                let newMapHeight = self.mapView.frame.height + newTranslation

                if newMapHeight > self.minMapHeight && newMapHeight < self.maxMapHeight {
                    self.tableViewHeightConstraint.constant -= newTranslation
                    self.prevTranslation = totalTranslation.y
                }

            case .Cancelled, .Ended:
                self.prevTranslation = 0

            case .Possible, .Failed:
                break
        }
    }

    func tableViewFullyDisplayed() -> Bool {
        return false
    }

    private func centerMap() {
        let latitudeDistance = abs(self.stop!.getLatitude() - self.currentLocation.coordinate.latitude).degreesToMeters()
        let longitudeDistance = abs(self.stop!.getLongitude() - self.currentLocation.coordinate.longitude).degreesToMeters()

        let averageLatitude = (self.stop!.getLatitude() + self.currentLocation.coordinate.latitude) / 2
        let averageLongitude = (self.stop!.getLongitude() + self.currentLocation.coordinate.longitude) / 2

        let averageLocation = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(averageLocation, latitudeDistance * 1.1, longitudeDistance * 1.1)

        self.mapView.setRegion(coordinateRegion, animated: false)
    }

    func updateTableSizeFor(height: CGFloat) {
        
    }

    // ugly way to do it. better ways?
    private func setDelegates() {
        for vc in (self.parentViewController?.parentViewController?.childViewControllers)! {
            if vc is FavoritesViewController {
                (vc as! FavoritesViewController).stopDelegate = self
            } else if vc is SearchViewController {
                (vc as! SearchViewController).stopDelegate = self
            }
        }
    }

}
