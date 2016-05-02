//
//  StopOverlayRenderer.swift
//  TransitAlarm
//
//  Created by id on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import MapKit
import UIKit

class StopOverlayRenderer: MKOverlayRenderer {

    var color: UIColor

    init(overlay:MKOverlay, color: UIColor) {
        self.color = color
        super.init(overlay: overlay)
    }

    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let rect = rectForMapRect(overlay.boundingMapRect)

        var R:CGFloat = 0
        var G:CGFloat = 0
        var B:CGFloat = 0
        var A:CGFloat = 0
        color.getRed(&R, green: &G, blue: &B, alpha: &A)

        CGContextSetRGBFillColor (context, 1, 1, 1, 0.5)
        CGContextFillEllipseInRect (context, rect)

        CGContextSetRGBStrokeColor (context, R, G, B, A)
        CGContextSetLineWidth (context, 30.0)
        CGContextStrokeEllipseInRect (context, rect)
    }
}