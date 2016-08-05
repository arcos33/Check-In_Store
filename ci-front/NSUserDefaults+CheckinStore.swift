//
//  NSUserDefaults+CheckinStore.swift
//  CheckIn-Store
//
//  Created by Joel on 7/30/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    func createUniqueID() -> Int {
        let uniqueID = self.integerForKey("uniqueID")
        self.setInteger(uniqueID + 1, forKey: "uniqueID")
        self.synchronize()
        
        return uniqueID
    }
}

