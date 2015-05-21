//
//  ViewController.swift
//  MarktKasse
//
//  Created by Kris Wolff on 07/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import UIKit
import CoreData


class AccountItem {
    let id: NSManagedObjectID
    let product: NSManagedObject
    var count: Int = 1
    init(product: NSManagedObject){
        self.product = product
        self.id = product.objectID
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProductActionDelegate {

    @IBOutlet weak var numberpanel: UITextField!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var checkoutButton: UIBarButtonItem!


    
    var entries = [NSManagedObject]()
    var categories = [NSManagedObject]()
    var account = [AccountItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view data
        productTable.dataSource = self
        productTable.delegate = self
        productTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Fetch all Products at once
        let fetchRequest = NSFetchRequest(entityName:"Product")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        if let results = fetchedResults {
            entries = results
        } else {
            NSLog("Could not fetch \(error), \(error!.userInfo)")
            let avv = UIAlertView(title: "Fehler", message: "Could not fetch \(error), \(error!.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }

        // Fetch all Categories at once
        let fetchRequestCategory = NSFetchRequest(entityName:"Category")
        var errorCategory: NSError?
        let fetchedResultsCategory = managedContext.executeFetchRequest(fetchRequestCategory, error: &errorCategory) as? [NSManagedObject]
        if let results = fetchedResultsCategory {
            categories = results
        } else {
            NSLog("Could not fetch \(error), \(error!.userInfo)")
            let avv = UIAlertView(title: "Fehler", message: "Could not fetch \(error), \(error!.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }

        // Long-Press
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        longpress.minimumPressDuration = 1.8
        let touchpress = UITapGestureRecognizer(target: self, action: "tapGestureRecognized:")
        productTable.addGestureRecognizer(longpress)
        productTable.addGestureRecognizer(touchpress)
        
        // Navigation
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"

            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].valueForKey("name") as? String
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        let products = entries.filter() {
            if $0.valueForKey("Category")?.objectID == category.objectID {
                return true
            }
            return false
        }
        return products.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("productcell",
                forIndexPath: indexPath) as! ProductCell
            let section = indexPath.section
            let category = categories[section]
            let products = entries.filter() {
                if $0.valueForKey("Category")?.objectID == category.objectID {
                    return true
                }
                return false
            }
            
            let item = products[indexPath.row]
            cell.id = item.objectID
            cell.productname.text = item.valueForKey("name") as? String
            cell.price = (item.valueForKey("price") as? Double)!
            cell.delegate = self
            dump(item)
            return cell
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        NSLog("long press")
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        var locationInView = longPress.locationInView(productTable)
        var indexPath = productTable.indexPathForRowAtPoint(locationInView)
        if state.rawValue == 1 {
            // editProductSegue
            performSegueWithIdentifier("editProductSegue", sender: self)
        }
        
    }
    
    func tapGestureRecognized(gestureRecognizer: UIGestureRecognizer){
        NSLog("tab")
        let tap = gestureRecognizer as! UITapGestureRecognizer
        let state = tap.state
        var locationInView = tap.locationInView(productTable)
        var indexPath = productTable.indexPathForRowAtPoint(locationInView)
        if state.rawValue == 3 {
            productTable.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(0.7 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(), {
                    if let path = indexPath {
                        self.productTable.deselectRowAtIndexPath(path, animated: true)
                    }
            })
        }

    }

    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("PREPARE FOR SEGUE")
        if segue.identifier == "editProductSegue" {
            if let controler: EditProductController = segue.destinationViewController as? EditProductController {
                
                controler.isEditMode = true
                
            }
            
        }
    }
    
    // MARK: UI
    
    func updateProductPrice(#id: NSManagedObjectID, add: Bool){
        if add {
            NSLog("Add \(id)")
            let item = account.filter({$0.id == id})
            if(item.count > 0){
                item.first?.count += 1;
            } else {
                if let product = entries.filter({$0.objectID == id}).first {
                    account.append(AccountItem(product: product))
                } else {
                    let avv = UIAlertView(title: "Fehler", message: "Produkt nicht gefunden.", delegate: nil, cancelButtonTitle: "Weiter")
                    avv.show()
                }
            }
        } else {
            for var i = 0; i < account.count; ++i {
                if id == account[i].id {
                    if account[i].count == 1 {
                        account.removeAtIndex(i)
                    } else {
                       account[i].count -= 1
                    }
                    break
                }
            }
            
        }
        updateCalculation()
    }
    
    func fnCalculatePrices(item: AccountItem) -> Double {
        return Double((item.product.valueForKey("price") as? Double)!) * Double(item.count)
    }
    
    func updateCalculation(){
        let prices = account.map(fnCalculatePrices)
        let total = prices.reduce(0) { (total, price) in total + price }
        let nf = NSNumberFormatter()
        nf.numberStyle = .CurrencyStyle

        numberpanel.text = nf.stringFromNumber(total)
    }

}

