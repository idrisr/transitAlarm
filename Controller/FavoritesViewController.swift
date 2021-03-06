//
//  FavoritesViewController.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    var stopIDs = [String]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var selectedStop: String!
    var moc: NSManagedObjectContext?
  
    var stops = [Stop]()
    var stopDelegate : StopDelegate?
    
    var userExists = false

    @IBOutlet weak var tableView: UITableView!

    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        moc = appDelegate.managedObjectContext
        self.navBar.delegate = self
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if checkForUser() {
            getTransitStops()
        }
    }
    
    func getTransitStops() {
        // do from NSUserDefaults
    }

    func loadStopData() {
        let request = NSFetchRequest.init(entityName: "Stop")
        let predicate = NSPredicate(format: "id in %@", stopIDs)
        request.predicate = predicate

        do {
            let result = try self.moc!.executeFetchRequest(request)
            self.stops = result as! [Stop]
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        self.tableView.reloadData()
    }

    // MARK: UINavigationBarDelegate
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stop = self.stops[indexPath.row]
        self.stopDelegate!.setAlarmForStop(stop)
        revealViewController().revealToggle(nil)
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell", forIndexPath: indexPath)
        let stop = stops[indexPath.row]
        cell.textLabel?.text = stop.name
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
        return cell
    }

    // MARK: private func stuff
    private func checkForUser() -> Bool {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            return true
        } else {
            return false
        }
    }

}
