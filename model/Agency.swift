//
//  Agency.swift
//  TransitAlarm
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//

import Foundation
import CoreData

func ==(lhs:Agency, rhs:Agency) -> Bool { // Implement Equatable
    return lhs.id == rhs.id
}

class Agency: NSManagedObject {

}
