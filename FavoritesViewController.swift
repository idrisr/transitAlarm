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
    var selectedStop: String!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?
  
    var objectStops = [Stop]()
    var stopDelegate : StopDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        moc = appDelegate.managedObjectContext
        
       
        currentUser = dataService.REF_CURRENT_USER
        getTransitStops()
        
        setBarButtonItemOnRight()
    }
    
    func setBarButtonItemOnRight() {
        let btnName = UIButton()
        btnName.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        btnName.addTarget(self, action: #selector(FavoritesViewController.skipPressed), forControlEvents: .TouchUpInside)
        btnName.setTitle("Skip", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.title = "Favorites"
    }
    
    func getTransitStops() {
        let ref = Firebase(url:"\(currentUser)/favorites")
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            let transitStops = snapshot.value.objectForKey("transitStop") as? String
            self.favoriteStops.append(transitStops!)
            print("\(self.favoriteStops)")
            self.tableView.reloadData()
        })
    }
    
    func skipPressed() {
        performSegueWithIdentifier("SkipSegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let request = NSFetchRequest.init(entityName: "Stop")
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
       performSegueWithIdentifier("MapSegue", sender: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell", forIndexPath: indexPath)
        cell.textLabel?.text = favoriteStops[indexPath.row]
        selectedStop = cell.textLabel?.text
        return cell
    }

    @IBAction func skipButtonSegue(sender: UIButton) {
        performSegueWithIdentifier("SkipSegue", sender: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "MapSegue" {
//               let destination = segue.destinationViewController as? MainViewController
//                let request = NSFetchRequest.init(entityName: "Stop")
//                do {
//                    let result = try self.moc!.executeFetchRequest(request)
//                    objectStops = result as! [Stop]
//                    for stopName in objectStops {
//                        if stopName.name == selectedStop {
//                            print(stopName.name)
//                            destination?.stop = stopName
//                        }
//                    }
//                } catch {
//                    let fetchError = error as NSError
//                    print(fetchError)
//                }
//            }
//        }
}
