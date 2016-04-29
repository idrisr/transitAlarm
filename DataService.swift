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
    private var _REF_TRANSIT_STOP = Firebase(url: "https://transit-alarm.firebaseio.com/transitStops")
    private var _REF_USER = Firebase(url: "https://transit-alarm.firebaseio.com/users")
    
    var transitStops = [String]()


    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_TRANSIT_STOP: Firebase {
        return _REF_TRANSIT_STOP
    }
    
    var REF_USER: Firebase {
        return _REF_USER
    }
    
    var REF_CURRENT_USER: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "https://transit-alarm.firebaseio.com").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    
    func createFirebaseUser(uid: String, user: Dictionary<String,String>) {
        REF_USER.childByAppendingPath(uid).setValue(user)
    }
    

}











