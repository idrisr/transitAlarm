//
//  Agency+CoreDataProperties.swift
//  TransitAlarm
//
//  Created by id on 4/26/16.
//  Copyright © 2016 id. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Agency {

    @NSManaged var id: String?
    @NSManaged var language: String?
    @NSManaged var name: String?
    @NSManaged var timezone: String?
    @NSManaged var url: String?
    @NSManaged var routes: NSSet?

}
