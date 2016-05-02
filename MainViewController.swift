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


class MainViewController: UIViewController {

    @IBOutlet weak var mapviewHeightConstraint: NSLayoutConstraint!

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
    var tableDataSource = TableDataSourceDelegate()

    var maxMapHeight: CGFloat?
    var minMapHeight: CGFloat?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationController = LocationController(mapView: mapView)
        self.locationController!.mapView = self.mapView

        revealViewController().rearViewRevealWidth = 300
        revealViewController().rightViewRevealWidth = 300
        
        openFavoritesButton.target = self.revealViewController()
        openFavoritesButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        searchButton.target = self.revealViewController()
        searchButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))

        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.delegate = self.tableDataSource

        self.tableView.delegate = self.tableDataSource
        self.tableView.dataSource = self.tableDataSource
        self.tableDataSource.mapView = self.mapView
        self.tableDataSource.locationDelegate = locationController

        self.minMapHeight = 50
        self.maxMapHeight = UIScreen.mainScreen().bounds.size.height - minMapHeight!
    }

    // MARK: IBActions
    @IBAction func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began, .Changed:
                // get change from last translation
                let totalTranslation = gesture.translationInView(gesture.view?.superview)
                let newTranslation = totalTranslation.y - self.prevTranslation
                let newMapHeight = self.mapView.frame.height + newTranslation

                if newMapHeight > self.minMapHeight && newMapHeight < self.maxMapHeight {
                    self.mapviewHeightConstraint.constant += newTranslation
                    self.prevTranslation = totalTranslation.y
                }

            case .Cancelled, .Ended:
                self.prevTranslation = 0

            case .Possible, .Failed:
                break
        }
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
}
