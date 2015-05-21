//
//  Account_Log.swift
//  MarktKasse
//
//  Created by Kris Wolff on 18/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import CoreData

class Account_Log: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var account: Account
    @NSManaged var product: Product

}
