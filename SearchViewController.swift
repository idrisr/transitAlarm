//
//  SearchViewController.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 5/2/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchBarIsSearching = false
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?
    
    var tableViewStops = [Stop]()
    var filteredTableViewStops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        moc = appDelegate.managedObjectContext
        
        loadAllStops()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarIsSearching {
            return filteredTableViewStops.count
        } else {
        return tableViewStops.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        let stop: Stop!
        if searchBarIsSearching {
            stop = filteredTableViewStops[indexPath.row]
        } else {
            stop = tableViewStops[indexPath.row]
        }
        cell.textLabel?.text = stop.name
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            searchBarIsSearching = false
            tableView.reloadData()
            view.endEditing(true)
            
        } else {
            searchBarIsSearching = true
            let lower = searchBar.text!.uppercaseString
            filteredTableViewStops = tableViewStops.filter({$0.name!.rangeOfString(lower) != nil})
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func loadAllStops() {
        let request = NSFetchRequest.init(entityName: "Stop")
        do {
            let result = try self.moc!.executeFetchRequest(request)
            tableViewStops = result as! [Stop]
            tableViewStops.sortInPlace({$0.name < $1.name})

        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

}
