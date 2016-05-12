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

protocol TableSizeDelegate {
    func adjustTableSize()
}

// FIXME: make part of AlertDelegate?
protocol StopAlertPopupDelegate {
    func showAlert(stop: Stop)
}

protocol AlertDelegate {
    func presentAlert(alert: UIAlertController, completionHandler: () -> ())
}

class CenterViewController: UIViewController {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var openFavoritesButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationController = LocationController()
    var transitTable = TransitTableController()
    var mapController :MapController?

    var currentLocation = CLLocation() // FIXME: why not in location controller?

    var prevTranslation: CGFloat = 0
    var minTableViewHeight: CGFloat?
    var didCenterMap = false // FIXME: why not in mapcontroller

    var stopUpdateDelegate: TransitDataStopUpdate?
    var mapDelegate: MapDelegate?
    var centerViewControllerDelegate: CenterViewControllerDelegate?

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mapController                  = MapController(mapView: mapView)
        mapDelegate                    = mapController
        transitTable.mapDelegate       = mapController
        locationController.mapDelegate = mapController
        mapView.delegate               = mapController

        tableView.delegate = transitTable
        tableView.dataSource = transitTable

        transitTable.locationDelegate = locationController
        transitTable.tableSizeDelegate = self
        transitTable.stopAlertPopupDelegate = self

        locationController.alertDelegate = self

        stopUpdateDelegate = self.transitTable
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsOnSwipe = true

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.alertDelegate = self

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
        return self.tableView.numberOfRowsInSection(tableSection.Agency.rawValue) == tableSection.Agency.minRows()
    }

    private func tableViewInStartPosition() -> Bool {
        // true if table has height for all agencies and one section header
        return abs(self.tableView.frame.height - CGFloat(tableSection.Agency.minRows()) * tableHeights.Row.height() + tableHeights.Header.height()) < 0.1
    }


    // ugly way to do it. better ways?
    private func setDelegatesFor(parentViewController: UIViewController) {
        for vc in parentViewController.childViewControllers {
            if vc is SearchViewController {
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

// MARK: AlertDelegate
extension CenterViewController: AlertDelegate {
    func presentAlert(alert: UIAlertController, completionHandler: () -> ()) {
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: StopAlertPopupDelegate
extension CenterViewController: StopAlertPopupDelegate {
    //FIXME: dont present a 2nd alert controller if already showing one
    //    2016-05-12 14:42:54.218 TransitAlarm[64076:38266662] Warning: Attempt to present <UIAlertController: 0x7fb530418500>  on <TransitAlarm.CenterViewController: 0x7fb529e4da70> which is already presenting <UIAlertController: 0x7fb5303cbb50>

    func showAlert(stop: Stop) {
        let title = "Location Alarm Set"
        let message = "Route: \(stop.route!.long_name!)\nStop: \(stop.name!)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)

        let delay = 2.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

// MARK: StopDelegate
extension CenterViewController: StopDelegate {
    func setAlarmForStop(stop: Stop) {
        self.stopUpdateDelegate!.setAlertFor(stop, tableView: self.tableView)
        self.mapDelegate!.clearMap()
        self.mapDelegate!.drawStop(stop)
        locationController.startMonitoringRegionFor(stop) // FIXME: should happen via delegate??
        self.mapDelegate!.setCenterOnCoordinate(stop.location2D, animated: true)
    }
}

// MARK: TableSizeDelegate
extension CenterViewController: TableSizeDelegate {
    func adjustTableSize() {
        UIView.animateWithDuration(0.4) {
            // change constraints inside animation block
            self.tableViewHeightConstraint.constant = self.defaultHeightForTable()

            // force layout inside animation block
            self.view.layoutIfNeeded()
        }
    }
}