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

class StopsViewController: UIViewController {

    let _apiURL = "https://data.cityofchicago.org/api/views/8pix-ypme/rows.xml?accessType=DOWNLOAD"

    @IBOutlet weak var tableView: UITableView!
    var transitProvider: String?
    var stops =  [Stop]()

    override func viewDidLoad() {
        super.viewDidLoad()

        switch transitProvider! {
        // get rid of this stringly typed shit
        case "CTA Train":
            downloadComplete()

        default:
            print("")
        }
    }

    func downloadComplete() {
        let url = NSURL(string: self._apiURL)!
        Alamofire.request(.GET, url).responseString { response in
            let result = response.result
            let xml = SWXMLHash.parse(result.value!)
            for stopXML in xml["response"]["row"]["row"] {
                let stop = Stop(xmlData: stopXML)
            }
        }

    }
}
