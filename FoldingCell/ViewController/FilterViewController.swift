//
//  FilterViewController.swift
//  Agenda Master
//
//  Created by Harun Gunaydin on 5/17/16.

import UIKit

class FilterViewController: UIViewController {

    
    func bringDeletedEventsBack() {
        
        var deletedItems = NSUserDefaults.standardUserDefaults().objectForKey("deletedItems") as! [String]
        
        for event in deletedItems {
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "deletedEventForId_" + event)
        }
        
        deletedItems.removeAll()
        NSUserDefaults.standardUserDefaults().setObject(deletedItems, forKey: "deletedItems")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
