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

class ViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    ProductActionDelegate,
UpdateProductDelegate {
    
    @IBOutlet weak var numberpanel: UITextField!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var checkoutButton: UIBarButtonItem!
    
    
    
    var entries = [NSManagedObject]()
    var categories = [NSManagedObject]()
    
    var account = [AccountItem]()
    var currentSelectedEntry: NSManagedObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        :NSDocumentDirectory inDomains:NSUserDomainMask
//        NSLog("app dir: %@",NSFileManager.defaultManager().URLsForDirectory);
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        println("App Path: \(dirPaths)")
        
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
            
            // get from account
            let accountItem = account.filter({$0.id == item.objectID})
            
            cell.id = item.objectID
            cell.managedObject = item
            cell.productname.text = item.valueForKey("name") as? String
            cell.price = (item.valueForKey("price") as? Double)!
            cell.reset(accountItem.first?.count ?? 0)
            
            cell.delegate = self
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
            if let cell = productTable.cellForRowAtIndexPath(indexPath!) as? ProductCell {
                NSLog("Set managed object")
                currentSelectedEntry = cell.managedObject!
            }
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
                controler.delegate = self
                controler.itemToEdit = currentSelectedEntry
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
        productTable.reloadData()
        productTable.setNeedsDisplay()
    }
    
    func productsDidUpdated() {
        productTable.reloadData()
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
    
    // Mark: Checkout
    
    @IBAction func checkoutAction(sender: AnyObject) {
        NSLog("Checkout")
        // create account
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let ctx = appDelegate.managedObjectContext!
        var error: NSError?
        
        let newAccount = NSEntityDescription.insertNewObjectForEntityForName("Account", inManagedObjectContext: ctx) as! Account
        
        newAccount.timestamp = NSDate()
        self.checkSave(ctx.save(&error), error: &error)
        
        println("Saved.")
        dump(newAccount.objectID)
        
        // link every product with a count to the accoutn relation
        account.map { (elm: AccountItem) -> () in
            let log = NSEntityDescription.insertNewObjectForEntityForName("Account_Log", inManagedObjectContext: ctx) as! Account_Log
            log.product = elm.product as! Product
            log.count = elm.count
            log.account = newAccount
            self.checkSave(ctx.save(&error), error: &error)
            
        }
        
        
        // clear view
        account.removeAll(keepCapacity: false)
        productTable.reloadData()
        updateCalculation();
    }
    
    func checkSave(save: Bool, inout error: NSError?){
        if save && error != nil {
            NSLog("Could not save data.")
            let avv = UIAlertView(title: "Fehler", message: "Could not save \(error), \(error!.userInfo)", delegate: nil, cancelButtonTitle: "Weiter")
            avv.show()
        }
    }
}

