//
//  FavoritesViewController.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dataService = DataService()
    var favoriteStops = [String]()
    var currentUser: Firebase!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var selectedStop: String!
    var moc: NSManagedObjectContext?
  
    var objectStops = [Stop]()
    var stopDelegate : StopDelegate?
    
    var userExists = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        moc = appDelegate.managedObjectContext
        if checkForUser() {
            getTransitStops()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if checkForUser() {
            getTransitStops()
            tableView.reloadData()
        }
    }
    
    func checkForUser() -> Bool {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            return true
        } else {
            return false
        }
    }
    
    func getTransitStops() {
        currentUser = dataService.REF_CURRENT_USER
        let ref = Firebase(url:"\(currentUser)/favorites")
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            let transitStops = snapshot.value.objectForKey("transitStop") as? String
            if self.favoriteStops.contains(transitStops!) {
                print("stop already included")
            } else {
            self.favoriteStops.append(transitStops!)
            }
            print("\(self.favoriteStops)")
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let request = NSFetchRequest.init(entityName: "Stop")
        self.selectedStop = favoriteStops[indexPath.row]
        // goes through all 7000 stops. use predicates instead on stop name
        do {
            let result = try self.moc!.executeFetchRequest(request)
            objectStops = result as! [Stop]
            for stopName in objectStops {
                if stopName.name == selectedStop {
                    print(stopName.name)
                    self.stopDelegate!.setAlarmForStop(stopName)
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        revealViewController().revealToggle(nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell", forIndexPath: indexPath)
        cell.textLabel?.text = favoriteStops[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
        return cell
    }

    @IBAction func skipButtonSegue(sender: UIButton) {
        performSegueWithIdentifier("SkipSegue", sender: nil)
    }
}
