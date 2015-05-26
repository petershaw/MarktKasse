//
//  Revenues.swift
//  MarktKasse
//
//  Created by Kris Wolff on 27/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import CoreData

class Revenues: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var amount: NSNumber

}
