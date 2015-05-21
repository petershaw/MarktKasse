//
//  EditProductViewController.swift
//  MarktKasse
//
//  Created by Kris Wolff on 10/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditProductController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var isEditMode = false {
        didSet {
            if isEditMode == true {
                // reset the back button
                if (backButton != nil) {
                    backButton.action = Selector("backAction:")
                }
            }
        }
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem! {
        didSet {
            if isEditMode == true {
                // reset the back button
                backButton.action = Selector("backAction:")
            }

        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var categoriePicker: UIPickerView! {
        didSet{
            categoriePicker.delegate = self
        }
    }
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var categories = [NSManagedObject]()
    var selectedCategory: NSManagedObject?
    
    override func viewDidLoad() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Category")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        if let results = fetchedResults {
            categories = results
            if categories.count > 0 {
                selectedCategory = categories.first
            }
        } else {
            NSLog("Could not fetch \(error), \(error!.userInfo)")
            let avv = UIAlertView(title: "Fehler", message: "Could not fetch \(error), \(error!.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }
    }
    
    // MARK: Picker
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let categorie = categories[row]
        return categorie.valueForKey("name") as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categorie = categories[row]
        selectedCategory = categorie
    }
    
    // MARK: Actions
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        NSLog("SAVE")
        
        if( self.nameField!.text.isEmpty || self.priceField!.text.isEmpty ){
            let avv = UIAlertView(title: "Fehler", message: "Name and price must not be empty.", delegate: nil, cancelButtonTitle: "OK")
            avv.show()
            return
        }
        
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("Product",
            inManagedObjectContext:
            managedContext)
        
        let product = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        product.setValue(self.nameField!.text, forKey: "name")
        product.setValue(Double((self.priceField!.text as NSString).doubleValue), forKey: "price")
        product.setValue(selectedCategory!, forKey: "category")
        dump(product)
        
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Could not save \(error), \(error?.userInfo)")
            let avv = UIAlertView(title: "Fehler", message: "Could not save \(error), \(error?.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }
    }
    
    func backAction(sender: AnyObject?) {
        NSLog("back action")
        if let nc = self.navigationController {
            NSLog("nav ctrl")
            dump(nc)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    
}