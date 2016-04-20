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
        // how to use the enum here?
        switch section {
            case CTATrainLine.Red.rawValue:           return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Red) }).count
            case CTATrainLine.Blue.rawValue:          return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Blue) }).count
            case CTATrainLine.Green.rawValue:         return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Green) }).count
            case CTATrainLine.Brown.rawValue:         return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Brown) }).count
            case CTATrainLine.Purple.rawValue:        return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Purple) }).count
            case CTATrainLine.PurpleExpress.rawValue: return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.PurpleExpress) }).count
            case CTATrainLine.Yellow.rawValue:        return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Yellow) }).count
            case CTATrainLine.Yellow.rawValue:        return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Yellow) }).count
            case CTATrainLine.Pink.rawValue:          return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Pink) }).count
            case CTATrainLine.Orange.rawValue:        return self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Orange) }).count
            default: return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var stopsForLine: [Stop]

        // surely there's a better less repetitive way and dont filter for each cell
        switch indexPath.section {
            case CTATrainLine.Red.rawValue:           stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Red) })
            case CTATrainLine.Blue.rawValue:          stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Blue) })
            case CTATrainLine.Green.rawValue:         stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Green) })
            case CTATrainLine.Brown.rawValue:         stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Brown) })
            case CTATrainLine.Purple.rawValue:        stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Purple) })
            case CTATrainLine.PurpleExpress.rawValue: stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.PurpleExpress) })
            case CTATrainLine.Yellow.rawValue:        stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Yellow) })
            case CTATrainLine.Yellow.rawValue:        stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Yellow) })
            case CTATrainLine.Pink.rawValue:          stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Pink) })
            case CTATrainLine.Orange.rawValue:        stopsForLine = self.stops.filter({ (stop) -> Bool in stop.lines.contains(CTATrainLine.Orange) })
            default: stopsForLine = []
        }

        let reuseID = "stopsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        let stop = stopsForLine[indexPath.row]
        cell.textLabel!.text = stop.stop_name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let stop = stops[indexPath.row]
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CTATrainLine.allValues.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CTATrainLine.allValues[section].name()
    }
}
