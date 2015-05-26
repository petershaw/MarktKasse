//
//  Product.swift
//  MarktKasse
//
//  Created by Kris Wolff on 25/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import CoreData

class Product: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var category: Category

}
