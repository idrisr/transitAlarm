//
//  RouteTableViewController.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

class RouteTableViewController: UITableViewController {

    var agency: Agency?
    var routes = [Route]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRoutes()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "routeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let route = self.routes[indexPath.row]
        cell.textLabel?.text = route.long_name
        return cell
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        let route = self.routes[indexPath!.row]
        let destinationVC = segue.destinationViewController as! StopTableViewController
        destinationVC.route = route
    }

    private func loadRoutes() {
        self.routes = (self.agency?.routes?.allObjects as? [Route])!
        self.routes.sortInPlace({$0.long_name < $1.long_name })
        self.tableView.reloadData()
    }
}
