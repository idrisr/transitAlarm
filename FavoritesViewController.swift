//
//  FavoritesViewController.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 4/27/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dataService = DataService()
    var favoriteStops = [String]()
    var currentUser: Firebase!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        performSegueWithIdentifier("MapSegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell", forIndexPath: indexPath)
        cell.textLabel?.text = favoriteStops[indexPath.row]
        return cell
    }

    @IBAction func skipButtonSegue(sender: UIButton) {
        performSegueWithIdentifier("SkipSegue", sender: nil)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let stopName: Stop!
        
        
    }

}
