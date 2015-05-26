//
//  ProductCalculation.swift
//  MarktKasse
//
//  Created by Kris Wolff on 27/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import CoreData

class ProductCalculation {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var error: NSError?
    
    private var _lastClosing: Revenues?
    var lastClosing: Revenues? {
        get {
            let ctx = appDelegate.managedObjectContext!
            let request = NSFetchRequest(entityName: "Revenues")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            request.fetchLimit = 1
            let result = ctx.executeFetchRequest(request, error: &error)
            if let objects = result as? [Revenues] {
                _lastClosing = objects.first
            }
            if (error != nil) {
                NSLog("fetch failed: \(error?.localizedDescription)")
            }
            return _lastClosing
        }
    }
    
    // get all products since the last closing
    func productsSinceLastClosing() -> [Account_Log] {
        let ctx = self.appDelegate.managedObjectContext!
        let request = NSFetchRequest(entityName: "Account_Log")
        if let lastClosing = self.lastClosing {
            request.predicate = NSPredicate(format: "timestamp >= %@", argumentArray: [lastClosing.date])
        }
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        var account_logs = ctx.executeFetchRequest(request, error: &self.error)

        if let objects = account_logs as? [Account_Log] {
            // count up all prices
            return objects
        }
        return [Account_Log]()
    }
    
    // turnover since last closing
    func amountSinceLastClosing() -> Double {
        let logs: [Account_Log] = self.productsSinceLastClosing()
        var amount: Double = 0
        amount = logs.reduce(Double(0)) { (total, element: Account_Log) in
            total + ( element.product.price.doubleValue * element.count.doubleValue )
        }
        return amount
    }

}