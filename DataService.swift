//
//  DataService.swift
//  TransitAlarm
//
//  Created by Matthew Bracamonte on 4/20/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation
import Firebase

class DataService {

static let dataService = DataService()
private var _REF_BASE = Firebase(url: "https://transit-alarm.firebaseio.com")

    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
}