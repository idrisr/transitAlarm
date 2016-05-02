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

    var overlayImage: UIImage

    init(overlay:MKOverlay, overlayImage:UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }

    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let imageReference = overlayImage.CGImage

        let theMapRect = overlay.boundingMapRect
        let theRect = rectForMapRect(theMapRect)

        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -theRect.size.height)
        CGContextDrawImage(context, theRect, imageReference)
    }
}