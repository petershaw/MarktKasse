//
//  MenuViewController.swift
//  MarktKasse
//
//  Created by Kris Wolff on 10/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    var textField: UITextField?
    
    var categories = [NSManagedObject]()
    
    func configurationTextField(textField: UITextField!) {
        if let tField = textField {
            self.textField = textField!        //Save reference to the UITextField
            self.textField!.text = ""
        }
    }
    
    @IBAction func newCategory(sender: UIButton) {
        var alert = UIAlertController(title: "Neue Kategorie", message: "Name der neuen Kategorie", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("save the cat")
            println( self.textField!.text )
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity =  NSEntityDescription.entityForName("Category",
                inManagedObjectContext:
                managedContext)
            
            let categorie = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            categorie.setValue(self.textField!.text, forKey: "name")
            
            var error: NSError?
            if !managedContext.save(&error) {
                NSLog("Could not save \(error), \(error?.userInfo)")
                let avv = UIAlertView(title: "Fehler", message: "Could not save \(error), \(error?.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
                avv.show()
            }
            self.categories.append(categorie)
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
}