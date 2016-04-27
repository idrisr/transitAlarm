//
//  StopTableViewController.swift
//  DBCreator
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

class StopTableViewController: UITableViewController {

    var route: Route?
    var stops = [Stop]()
    var shapes = [Shape]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRoutes()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "stopCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let stop = self.stops[indexPath.row]

        cell.textLabel!.text = stop.name
        let lat = Float(stop.latitude!)
        let lon = Float(stop.longitude!)
        let seq = Int(stop.sequence!)
        cell.detailTextLabel!.text = String(format: "%.2f", lat!) + " " + String(format: "%.2f", lon!) + " " + "\(seq!)"
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        let stop = self.stops[indexPath!.row]
        let destinationVC = segue.destinationViewController as! MapViewController
        destinationVC.stop = stop
    }

    private func loadRoutes() {
        self.stops = (self.route?.stops?.allObjects as? [Stop])!
        stops.sortInPlace( { Int($0.sequence!) > Int($1.sequence!) } )

        self.shapes = (self.route?.shapes?.allObjects as? [Shape])!
        shapes.sortInPlace( { Int($0.sequence!) > Int($1.sequence!) } )
//        print(shapes)
        self.tableView.reloadData()
    }
    
}
