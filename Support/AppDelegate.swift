//
//  AppDelegate.swift
//  TransitAlarm
//
//  Created by id on 4/18/16.
//  Copyright © 2016 id. All rights reserved.
//

import AVFoundation
import CoreData
import CoreLocation
import UIKit

//FIXME: bug - didnt work when app was in background and hit the stop
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    let model = "transit"
    let db = "chicago"
    let locationController = LocationController.sharedInstance
    var alertDelegate: AlertDelegate?
    var player: AVAudioPlayer!

    // FIXME: turn off compass calibration
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alert = UIAlertController(title: "At your stop", message: "Get Off!", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (alert) in
            self.player.stop()
        }

        AudioServicesPlaySystemSound(4095) // vibrate
        do {
            let sound = NSBundle.mainBundle().pathForResource("alarm", ofType: "wav")
            let url = NSURL(fileURLWithPath: sound!)
            self.player = try AVAudioPlayer(contentsOfURL: url)
            self.player.play()
        } catch {
            print(error)
        }

        alert.addAction(cancelAction)
        self.alertDelegate?.presentAlert(alert, completionHandler: {})

    }

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        // FIXME: sometimes gets a Received memory warning
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // FIXME: make me less confusing
        // FIXME: somehow loyola seems always set upon app launch
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            try session.setActive(true)
        } catch {
            print(error)
        }

        locationController.locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // TODO: check here that permission was given for alerts
    }

    // FIXME: what happens to the alarm in these 4 conditions?
    func applicationDidEnterBackground(application: UIApplication) { }
    func applicationWillEnterForeground(application: UIApplication) { }
    func applicationDidBecomeActive(application: UIApplication) { }
    func applicationWillTerminate(application: UIApplication) { }

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.idrisr.CoreDataDeleteMe" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("\(self.model)", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.db).sqlite")

        // Load the existing database
        if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {

            let sourceSqliteURLs = [NSBundle.mainBundle().URLForResource("\(self.db)", withExtension: "sqlite")!]

            let destSqliteURLs = [self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.db).sqlite")]

            for index in 0..<sourceSqliteURLs.count {
                do {
                    try NSFileManager.defaultManager().copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index])
                } catch {
                    print(error)
                }
            }
        }

        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

