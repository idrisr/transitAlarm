//
//  AlertCatalog.swift
//  TransitAlarm
//
//  Created by id on 5/15/16.
//  Copyright © 2016 id. All rights reserved.
//

import AVFoundation
import UIKit

typealias completionHandler = ( () -> () )? // (⊙)﹏(⊙)


class AlertCatalog {
    static var player: AVAudioPlayer!
    static var session: AVAudioSession!

    class func destinationAlert(notification: UILocalNotification) -> (UIAlertController, completionHandler) {
        do {
            AudioServicesPlaySystemSound(4095) // vibrate
            self.session = AVAudioSession.sharedInstance()

            try self.session.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.DuckOthers)
            try self.session.setActive(true)
            let sound = NSBundle.mainBundle().pathForResource("alarm", ofType: "wav")
            let url = NSURL(fileURLWithPath: sound!)
            self.player = try AVAudioPlayer(contentsOfURL: url)
            self.player.play()
        } catch {
            print(error)
        }

        let alert = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (alert) in
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0), {
                do {
                    self.player.stop()
                    try self.session.setActive(false)
                } catch {
                    print(error)
                }
            })
        }

        alert.addAction(cancelAction)
        return (alert: alert, completionHandler: nil)
    }

    class func locationPermission() -> (UIAlertController, completionHandler) {
        // FIXME, improve this message +
        // TODO: Deep link to settings
        let title = "Location Permissions Not Enabled"
        let message = "Transit Alarm requires access to your location to inform you when your stop is nearing. Go to Settings->Location and enable location for this app for alarms to be set"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)

        return (alert: alert, completionHandler: nil)
    }

    class func notificationPermission() -> (UIAlertController, completionHandler) {
        // FIXME, improve this message +
        // TODO: Deep link to settings
        let title = "Notifications Not Enabled"
        let message = "Transit Alarm will send you notifications when you set an alarm and your stop is approaching. To allow notifications go to Settings->TransitAlarm"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        return (alert: alert, completionHandler: nil)
    }

    class func stopSetAlert(stop: Stop) -> (UIAlertController, completionHandler) {
        let title = "Location Alarm Set"
        let message = "Route: \(stop.route!.long_name!)\nStop: \(stop.name!)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        return (alert: alert, completionHandler: nil)
    }
}