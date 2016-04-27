//
//  AgencyTableViewController.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import CoreData

class AgencyTableViewController: UITableViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext?
    var agencies = [Agency]()

    override func viewDidLoad() {
        super.viewDidLoad()
        moc = appDelegate.managedObjectContext
        self.title = "Agency";
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadAgencies()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agencies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "agencyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let agency = self.agencies[indexPath.row]
        cell.textLabel?.text = agency.name
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        let agency = self.agencies[indexPath!.row]
        let destinationVC = segue.destinationViewController as! RouteTableViewController
        destinationVC.agency = agency
    }

    private func loadAgencies() {
        let request = NSFetchRequest.init(entityName: "Agency")

        do {
            let result = try self.moc!.executeFetchRequest(request)
            agencies = result as! [Agency]
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}
