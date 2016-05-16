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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    let model = "transit"
    let db = "chicago"
    let locationController = LocationController.sharedInstance
    var alertDelegate: AlertDelegate?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        self.locationController.stopMonitoringRegion()
        switch (UIApplication.sharedApplication().applicationState) {
            case .Active:
                let (alert, completion) = AlertCatalog.destinationAlert(notification)
                self.alertDelegate?.presentAlert(alert, completion: completion)
            case .Inactive, .Background:
                break
        }
    }

    // TODO: sometimes gets a Received memory warning
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        // shows up when rapidly zooming map
        NSLog("\(NSThread.callStackSymbols().joinWithSeparator("\n"))")
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationController.locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if !self.notificationSettings {
            let (alert, completion) = AlertCatalog.notificationPermission()
            self.alertDelegate?.presentAlert(alert, completion: completion)
        }
    }

    var notificationSettings: Bool {
        get {
            let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
            return notificationSettings.types.contains(.Alert) && notificationSettings.types.contains(.Sound)
        }
    }

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("\(self.model)", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
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

