//
//  ProductCell.swift
//  MarktKasse
//
//  Created by Kris Wolff on 09/05/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ProductActionDelegate {
    func updateProductPrice(#id: NSManagedObjectID, add: Bool)
}

class ProductCell: UITableViewCell {

    var lastcount: Int = 0
    var price: Double = 0.0
    
    var delegate: ProductActionDelegate?
    
    var id: NSManagedObjectID = NSManagedObjectID()
    var managedObject: NSManagedObject?
    
    @IBOutlet weak var productname: UILabel!
    
    @IBOutlet weak var productcount: UILabel! {
        didSet{
            productcount.text = "\(lastcount) x"
        }
    }
    
    @IBOutlet weak var productstepper: UIStepper!
    
    @IBAction func stepperValueDidChanged(sender: UIStepper) {
        if Int(sender.value) > lastcount {
            delegate?.updateProductPrice(id: self.id, add: true)
        } else {
            delegate?.updateProductPrice(id: self.id, add: false)
        }
        lastcount = Int(sender.value)
    }
    
    func reset(count: Int?){
        let c = Double(count ?? 0)
        lastcount = count ?? 0
        productstepper.value = c
        productcount.text = "\(Int(c)) x"
    }
    
}