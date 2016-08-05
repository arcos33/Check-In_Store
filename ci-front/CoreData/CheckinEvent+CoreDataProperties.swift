//
//  CheckinEvent+CoreDataProperties.swift
//  CheckIn-Store
//
//  Created by Joel on 7/30/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CheckinEvent {

    @NSManaged var uniqueID: NSNumber?
    @NSManaged var checkinTimestamp: NSDate?
    @NSManaged var completedTimestamp: NSDate?
    @NSManaged var clientID: NSNumber?
    @NSManaged var serviceTypeID: NSNumber?
    @NSManaged var name: NSString?
    @NSManaged var wirelessProvider: NSString?
    @NSManaged var phone: NSString?
    @NSManaged var status: NSString?
}
