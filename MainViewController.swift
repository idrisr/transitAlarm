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

class MainViewController: UIViewController, StopDelegate {

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

    var minTableViewHeight: CGFloat?

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

        self.minTableViewHeight = 50
    }

    // MARK: StopDelegate
    func setAlarmForStop(stop: Stop) {
        self.stopUpdateDelegate!.setAlertFor(stop, tableView: self.tableView)
    }

    // MARK: IBActions
    @IBAction func handlePan(gesture: UIPanGestureRecognizer) {
//        print("default: \(self.defaultHeightForTable()) max: \(self.maxHeightForTable())")

        switch gesture.state {
            case .Began, .Changed:

                let totalTranslation = gesture.translationInView(gesture.view?.superview)
                let newTranslation = totalTranslation.y - self.prevTranslation
                let newTableViewHeight = self.tableView.frame.height - newTranslation

                switch scrollDirectionFor(gesture) {
                    case .Up:
                        // would be too tall
                        if newTableViewHeight >= maxHeightForTable() {
                            if self.tableView.frame.height <= maxHeightForTable() {
                                // cant move the entire pan, but can move some of the pan
                                let adjTranslation = maxHeightForTable() - self.tableView.frame.height
                                self.adjustHeightConstraintTo(adjTranslation, totalTranslation: totalTranslation)
                            }
                            else {
                                self.prevTranslation = 0
                            }
                        } else {
                            self.adjustHeightConstraintTo(newTranslation, totalTranslation: totalTranslation)
                        }
                    case .Down:
                        // would be too short
                        if newTableViewHeight <= minTableViewHeight {
                            self.prevTranslation = 0
                        } else {
                            self.adjustHeightConstraintTo(newTranslation, totalTranslation: totalTranslation)
                        }
                }

            case .Cancelled, .Ended:
                self.prevTranslation = 0

            case .Possible, .Failed:
                break
        }
    }

    private func adjustHeightConstraintTo(newTranslation: CGFloat, totalTranslation: CGPoint) {
        self.tableViewHeightConstraint.constant -= newTranslation
        self.prevTranslation = totalTranslation.y
    }

    // MARK: TableSizeUpdateDelegate
    func updateTableSizeFor(height: CGFloat) { }

    // MARK: private helper funcs to manage table view size
    private func scrollDirectionFor(gesture: UIPanGestureRecognizer) -> direction {
        // direction of pan. Up is making the tableview larger
        let netTranslation = gesture.translationInView(gesture.view).y - self.prevTranslation
        if netTranslation < 0 {
            return .Up
        } else {
            return .Down
        }
    }

    private func tableViewInStartState() -> Bool {
        // true if table is showing all the agencies and nothing else, aka the starting state
        return self.tableView.numberOfRowsInSection(tableSection.Agency.rawValue) == kAGENCYS
    }

    private func tableViewInStartPosition() -> Bool {
        // true if table has height for all agencies and one section header
        return abs(self.tableView.frame.height - CGFloat(kAGENCYS * tableHeights.Row.height() + tableHeights.Header.height())) < 0.1
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

    private func defaultHeightForTable() -> CGFloat {
        let sections = tableView.numberOfSections
        let minRows = tableSection(rawValue: sections)!.minRows()
        let rows = min(self.rowsInTable(), minRows)
        return self.heightForRows(rows, sections: sections)
    }

    private func maxHeightForTable() -> CGFloat {
        let rows = self.rowsInTable()
        let rowHeight = rows * tableHeights.Row.height()
        let sectionHeight = tableView.numberOfSections * tableHeights.Header.height()
        return CGFloat(rowHeight + sectionHeight)
    }

    private func heightForRows(rows:Int, sections: Int) -> CGFloat {
        let rowHeight = rows * tableHeights.Row.height()
        let sectionHeight = sections * tableHeights.Header.height()
        return CGFloat(rowHeight + sectionHeight)
    }

    private func rowsInTable() -> Int {
        var rows = 0
        let sectionCount = self.tableView.numberOfSections - 1
        for i in 0...sectionCount {
            rows += self.tableView.numberOfRowsInSection(i)
        }
        return rows
    }
}
