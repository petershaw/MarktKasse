//
//  CurrentRevenueViewController.swift
//  MarktKasse
//
//  Created by Kris Wolff on 26/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CurrentRevenueViewController: UIViewController {
    
    @IBOutlet weak var amount: UILabel!
    
    @IBAction func endOfDayAction(sender: UIButton) {
        NSLog("endOfDay")
        var alert = UIAlertController(title: "Tagesabschluß wirklich durchführen?", message: "Die Zähler werden auf null gestellt. Diese Aktion kann nicht rückgängig gemacht werden.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("do end of day now...")
            
            
            // save revenue
            let ctx = self.appDelegate.managedObjectContext!
            let revenue = NSEntityDescription.insertNewObjectForEntityForName("Revenues", inManagedObjectContext: ctx) as! Revenues
           
            revenue.date = NSDate()
            revenue.amount = self.calculations.amountSinceLastClosing()
            
            ctx.save(&self.error)
            if (self.error != nil) {
                NSLog("Error beim Tagesabschluß");
            }
            // clear screen
            self.amount.text = self.currencyFormatter.stringFromNumber(
                self.calculations.amountSinceLastClosing()
            )
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    let calculations = ProductCalculation()
    var lastClosing: Revenues?
    
    var error: NSError?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let currencyFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("CurrentRevenueViewController did load")
        
        currencyFormatter.numberStyle = .CurrencyStyle
        amount.text = currencyFormatter.stringFromNumber(
            calculations.amountSinceLastClosing()
        )
    }
    
}