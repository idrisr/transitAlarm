//
//  AlertCatalog.swift
//  TransitAlarm
//
//  Created by id on 5/15/16.
//  Copyright © 2016 id. All rights reserved.
//

import AVFoundation
import UIKit

class AlertFactory {
    // FIXME: probably not the factory pattern. Rename or re-factor(y)
    static var player: AVAudioPlayer!
    static var session: AVAudioSession!

    class func destinationAlert(notification: UILocalNotification) -> UIAlertController {
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
        return alert
    }
}