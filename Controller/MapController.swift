//
//  MapController.swift
//  TransitAlarm
//
//  Created by id on 5/6/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

// TODO: protocol extension of MKMapViewDelegate good idea?
// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html#//apple_ref/doc/uid/TP40014097-CH25-ID521

protocol MapDelegate {
    func drawRoute(route: Route) // draws routes, no destination set
    func drawStop(stop: Stop)    // sets destination
    func clearMap()
    func removeStopPin()
    func setCenterOnCoordinate(coordinate:CLLocationCoordinate2D, animated: Bool)
    func addOverlay(overlay: MKOverlay)
    func setRegion(coordinateRegion: MKCoordinateRegion, animated: Bool)
}

class MapController: NSObject {
    let mapView: MKMapView

    init(mapView: MKMapView) {
        // FIXME: set maprect at startup so its the right zoom level
        // see: func setVisibleMapRect(_ mapRect: MKMapRect, animated animate: Bool)

        // MKMapRect
        // MKMapPoint x,y on map - MKMapPointForCoordinate

        // MKCoordinateRegion
        // MKCoordinateSpan
        // MKCoor
        // MKMapsize

        self.mapView = mapView
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = false
        self.mapView.showsPointsOfInterest = false
        self.mapView.userTrackingMode = .FollowWithHeading


//        self.mapView.setVisibleMapRect(<#T##mapRect: MKMapRect##MKMapRect#>, animated: true)
//        MKMapRect
        let point = MKMapPoint(

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

    // MARK: map helpers
    private func addStopPin(stop: Stop) {
        let stopAnnotation = MKPointAnnotation()
        stopAnnotation.coordinate = stop.location2D
        self.mapView.addAnnotation(stopAnnotation)
    }

    private func removeRouteFromMap() {
        for overlay in self.mapView.overlays {
            if overlay is RouteLine  {
                self.mapView.removeOverlay(overlay)
            }
        }
        self.removeStopOverlays()
        self.removeStopAnnotations()
    }

    private func removeStopOverlays() {
        for overlay in self.mapView.overlays {
            if overlay is StopMapOverlay {
                self.mapView.removeOverlay(overlay)
            }
        }
    }

    private func removeStopAnnotations() {
        for annotation in self.mapView.annotations {
            if annotation is StopAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
}

// MARK: MKMapViewDelegate
extension MapController: MKMapViewDelegate {
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
}

// MARK: MapDelegate
extension MapController: MapDelegate {
    func setCenterOnCoordinate(coordinate:CLLocationCoordinate2D, animated: Bool) {
        UIView.animateWithDuration(1.0) {
            self.mapView.setCenterCoordinate(coordinate, animated: animated)
        }
    }

    func drawRoute(route: Route) {
        mapView.addOverlay(route.shapeLine)
        mapView.addOverlays(route.stopOverlays)
    }

    func drawStop(stop: Stop) {
        let route = stop.route!
        self.drawRoute(route)
        mapView.addOverlay(route.shapeLine)
        mapView.addOverlays(route.stopOverlays)
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
}