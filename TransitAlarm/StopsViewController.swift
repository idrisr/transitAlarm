//
//  StopViewController.swift
//  TransitAlarm
//
//  Created by id on 4/18/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let _apiURL = "https://data.cityofchicago.org/api/views/8pix-ypme/rows.xml?accessType=DOWNLOAD"

    @IBOutlet weak var tableView: UITableView!
    var transitProvider: String?
    var stops =  [Stop]()

    // FIXME: enum me!
    let lines = ["red", "blue", "green", "brown", "purple", "purple_exp", "yellow", "pink", "orange"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        switch transitProvider! {
        // get rid of this stringly typed shit
        case "CTA Train":
            downloadCTATrainData()

        default:
            print("")
        }
    }

    func downloadCTATrainData() {
        let url = NSURL(string: self._apiURL)!
        Alamofire.request(.GET, url).responseString { response in
            let result = response.result
            let xml = SWXMLHash.parse(result.value!)
            for stopXML in xml["response"]["row"]["row"] {
                let stop = Stop(xmlData: stopXML)
                self.stops.append(stop)
            }
            self.tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "stopsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let stop = stops[indexPath.row]
        cell.textLabel!.text = stop.stop_name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stop = stops[indexPath.row]
        print(stop.location)
    }

//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.lines.count;
//    }
//
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.lines[section]
//    }
}
