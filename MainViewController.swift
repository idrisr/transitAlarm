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

protocol TransitMapDelegate {
    func drawRoute(route: Route) // draws routes, no destination set
    func drawStop(stop: Stop)    // sets destination
    func clearMap()
    func removeStopPin()

    func setCenterOnCoordinate(coordinate:CLLocationCoordinate2D, animated: Bool)

    func addOverlay(overlay: MKOverlay)
    func setRegion(coordinateRegion: MKCoordinateRegion, animated: Bool)
}

protocol TableSizeDelegate {
    func adjustTableSize()
}

class MainViewController: UIViewController,
                          StopDelegate,
                          MKMapViewDelegate,
                          TableSizeDelegate,
                          TransitMapDelegate {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    let dataService = DataService()
    var stop: Stop?

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var openFavoritesButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationController = LocationController()
    var prevTranslation: CGFloat = 0
    var currentLocation = CLLocation()
    var didCenterMap = false
    var transitTable = TransitTableController()
    var stopUpdateDelegate: TransitDataStopUpdate?
    var favoriteStopDelegate: StopFavoriteDelegate?
    var minTableViewHeight: CGFloat?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationController.transitMapDelegate = self
        self.favoriteStopDelegate = locationController

        revealViewController().rearViewRevealWidth = 300
        revealViewController().rightViewRevealWidth = 300

        self.setDelegatesFor(revealViewController())

        openFavoritesButton.target = self.revealViewController()
        openFavoritesButton.action = #selector(SWRevealViewController.revealToggle(_:))

        searchButton.target = self.revealViewController()
        searchButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))

        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .FollowWithHeading

        self.tableView.delegate = self.transitTable
        self.tableView.dataSource = self.transitTable

        self.transitTable.locationDelegate = locationController
        self.transitTable.tableSizeDelegate = self
        self.transitTable.transitMapDelegate = self

        self.stopUpdateDelegate = self.transitTable
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsOnSwipe = true

        self.title = "Transit Alarm"
    }

    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }

    override func viewDidAppear(animated: Bool) {
        self.tableViewHeightConstraint.constant = self.defaultHeightForTable()
    }

    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is RouteLine {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = (overlay as! RouteLine).color
            renderer.lineWidth = 8.0
            return renderer
        } else if overlay is StopMapOverlay {
            let stopOverlay = overlay as! StopMapOverlay
            return StopOverlayRenderer(overlay: stopOverlay, color: stopOverlay.color)
        } else {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            return circleRenderer
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if annotation is MKPointAnnotation {
            let flag = MKAnnotationView()
            flag.image = UIImage(named: "checkeredFlag")
            return flag
        } else {
            return nil
        }
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
    }

    // MARK: StopDelegate
    func setAlarmForStop(stop: Stop) {
        self.stopUpdateDelegate!.setAlertFor(stop, tableView: self.tableView)
        self.clearMap()
        self.drawStop(stop)
        // should happen via delegate
        locationController.startMonitoringRegionFor(stop)
        self.setCenterOnCoordinate(stop.location2D, animated: true)
    }

    // MARK: IBActions
    @IBAction func handlePan(gesture: UIPanGestureRecognizer) {
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
                        if newTableViewHeight <= minHeightForTable() {
                            if self.tableView.frame.height >= minHeightForTable() {
                                // cant move the entire pan, but can move some of the pan
                                let adjTranslation = self.tableView.frame.height - minHeightForTable()
                                self.adjustHeightConstraintTo(adjTranslation, totalTranslation: totalTranslation)
                            }
                            else {
                                self.prevTranslation = 0
                            }
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
    func adjustTableSize() {
        UIView.animateWithDuration(0.4) {
            // change constraints inside animation block
            self.tableViewHeightConstraint.constant = self.defaultHeightForTable()

            // force layout inside animation block
            self.view.layoutIfNeeded()
        }
    }

    // MARK: TransitMapDelegate
    func setCenterOnCoordinate(coordinate:CLLocationCoordinate2D, animated: Bool) {
        UIView.animateWithDuration(1.0) {
            self.mapView.setCenterCoordinate(coordinate, animated: animated)
            // force layout inside animation block
            self.view.layoutIfNeeded()
        }
    }

    func drawRoute(route: Route) {
        self.mapView.addOverlay(route.shapeLine)
        self.mapView.addOverlays(route.stopOverlays)
    }

    func drawStop(stop: Stop) {
        let route = stop.route!
        self.drawRoute(route)
        self.mapView.addOverlay(route.shapeLine)
        self.mapView.addOverlays(route.stopOverlays)
        self.addStopPin(stop)
    }

    func clearMap() {
        removeRouteFromMap()
        removeStopOverlays()
        removeStopAnnotations()
        removeStopPin()
    }

    func removeStopPin() {
        for annotation in self.mapView.annotations {
            if annotation is MKPointAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
        for overlay in self.mapView.overlays {
            if overlay is MKCircle {
                self.mapView.removeOverlay(overlay)
            }
        }
    }

    func addOverlay(overlay: MKOverlay) {
        self.mapView.addOverlay(overlay)
    }

    func setRegion(coordinateRegion: MKCoordinateRegion, animated: Bool) {
        self.mapView.setRegion(coordinateRegion, animated: animated)
    }

    func centerOnUser() {}
    func centerOnRoute(){}
    func centerOnStop() {}

    // MARK: map helpers
    private func addStopPin(stop: Stop) {
        let stopAnnotation = MKPointAnnotation()
        stopAnnotation.coordinate = stop.location2D
        self.mapView.addAnnotation(stopAnnotation)
    }

    private func removeRouteFromMap() {
        for overlay in self.mapView!.overlays {
            if overlay is RouteLine  {
                self.mapView?.removeOverlay(overlay)
            }
        }
        self.removeStopOverlays()
        self.removeStopAnnotations()
    }

    private func removeStopOverlays() {
        for overlay in self.mapView!.overlays {
            if overlay is StopMapOverlay {
                self.mapView?.removeOverlay(overlay)
            }
        }
    }

    private func removeStopAnnotations() {
        for annotation in self.mapView!.annotations {
            if annotation is StopAnnotation {
                self.mapView?.removeAnnotation(annotation)
            }
        }
    }

    // is this used???
    private func centerMap() {
        let latitudeDistance = abs(self.stop!.getLatitude() - self.currentLocation.coordinate.latitude).degreesToMeters()
        let longitudeDistance = abs(self.stop!.getLongitude() - self.currentLocation.coordinate.longitude).degreesToMeters()

        let averageLatitude = (self.stop!.getLatitude() + self.currentLocation.coordinate.latitude) / 2
        let averageLongitude = (self.stop!.getLongitude() + self.currentLocation.coordinate.longitude) / 2

        let averageLocation = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(averageLocation, latitudeDistance * 1.1, longitudeDistance * 1.1)

        self.mapView.setRegion(coordinateRegion, animated: false)
    }

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
        return abs(self.tableView.frame.height - CGFloat(kAGENCYS) * tableHeights.Row.height() + tableHeights.Header.height()) < 0.1
    }


    // ugly way to do it. better ways?
    private func setDelegatesFor(parentViewController: UIViewController) {
        for vc in parentViewController.childViewControllers {
            if vc is FavoritesViewController {
                (vc as! FavoritesViewController).stopDelegate = self
            } else if vc is SearchViewController {
                (vc as! SearchViewController).stopDelegate = self
            }
        }
    }

    private func defaultHeightForTable() -> CGFloat {
        let sections = tableView.numberOfSections
        let minRows = tableSection(rawValue: sections - 1)!.minRows() // -1 to go to 0-indices
        let rows = min(self.rowsInTable(), minRows)
        return self.heightForRows(rows, sections: sections)
    }

    private func minHeightForTable() -> CGFloat {
        let rows = tableHeights.Row.minVisible()
        let sections = tableHeights.Header.minVisible()
        return heightForRows(rows, sections: sections)
    }

    private func maxHeightForTable() -> CGFloat {
        let rows = self.rowsInTable()
        let sections = tableView.numberOfSections
        return heightForRows(rows, sections: sections)
    }

    private func heightForRows(rows:Int, sections: Int) -> CGFloat {
        let rowHeight = CGFloat(rows) * tableHeights.Row.height()
        let sectionHeight = CGFloat(sections) * tableHeights.Header.height()
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