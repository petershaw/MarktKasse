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

protocol UpdateProductDelegate {
    func productsDidUpdated()
}

class EditProductController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    private var isEditMode = false {
        didSet {
            if isEditMode == true {
                // reset the back button
                if (backButton != nil) {
                    backButton.action = Selector("backAction:")
                }
            }
        }
    }
    
    var itemToEdit: NSManagedObject? {
        didSet {
            self.isEditMode = true
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
    
    var originalDeleteTitle: String?
    @IBOutlet weak var deleteProductButton: UIBarButtonItem! {
        didSet {
            originalDeleteTitle = deleteProductButton.title
            deleteProductButton.enabled = false
            deleteProductButton.title = ""
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var categoriePicker: UIPickerView! {
        didSet{
            categoriePicker.delegate = self
        }
    }
    var delegate: UpdateProductDelegate? = nil;
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
        
        if isEditMode {
            // set fields
            nameField.text = itemToEdit?.valueForKey("name") as! String
            if let price = itemToEdit?.valueForKey("price") as? Double! {
                priceField.text = "\(price)"
            }
            let c: AnyObject? = itemToEdit?.valueForKey("category")
            if let c: AnyObject = c {
                println(c.valueForKey("name"))
                if let index = find(categories, c as! NSManagedObject) {
                    categoriePicker.selectRow(index, inComponent: 0, animated: false)
                }
            }
            
            // enable delete button
            deleteProductButton.title = originalDeleteTitle
            deleteProductButton.enabled = true
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
        
        if isEditMode {
            itemToEdit?.setValue(self.nameField!.text, forKey: "name")
            itemToEdit?.setValue(Double((self.priceField!.text as NSString).doubleValue), forKey: "price")
            itemToEdit?.setValue(selectedCategory!, forKey: "category")
        } else {
            let product = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
        
            product.setValue(self.nameField!.text, forKey: "name")
            product.setValue(Double((self.priceField!.text as NSString).doubleValue), forKey: "price")
            product.setValue(selectedCategory!, forKey: "category")
        }

        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Could not save \(error), \(error?.userInfo)")
            let avv = UIAlertView(title: "Fehler", message: "Could not save \(error), \(error?.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }
        if isEditMode {
            backAction(nil)
        } else {
            // clear all and let the user edit another product.
            nameField.text = ""
            priceField.text = ""
            //selectedCategory  = nil
            
        }
    }
    
    // MARK: Categorries
    var textField: UITextField?
    
    func configurationTextField(textField: UITextField!) {
        if let tField = textField {
            self.textField = textField!        //Save reference to the UITextField
            self.textField!.text = ""
        }
    }
    
    @IBAction func deleteCategory(sender: UIButton) {
        var alert = UIAlertController(title: "Kategorie löschen", message: "Alle Produkte werden gelöscht.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("remove the cat")
            let managedContext = self.appDelegate.managedObjectContext!
            managedContext.deleteObject(self.selectedCategory!)
            self.categoriePicker.reloadAllComponents()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
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
            self.categoriePicker.reloadAllComponents()
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    @IBAction func deleteProductAction(sender: AnyObject) {
        var alert = UIAlertController(title: "Produkt löschen", message: "Dieses Produkte wirklich löschen?.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Löschen", style: UIAlertActionStyle.Default, handler: { action in
            println("remove the product")
            self.itemToEdit?.setValue(nil, forKey: "category")
            let managedContext = self.appDelegate.managedObjectContext!
            var error: NSError?
            if !managedContext.save(&error) {
                NSLog("Could not save \(error), \(error?.userInfo)")
                let avv = UIAlertView(title: "Fehler", message: "Could not save \(error), \(error?.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
                avv.show()
            }
            self.backAction(nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    func backAction(sender: AnyObject?) {
        NSLog("back action")
        if let delegate = delegate {
            delegate.productsDidUpdated()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Mark: Checkout
    
    
    
    
    
}