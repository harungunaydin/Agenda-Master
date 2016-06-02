//
//  FilterViewController.swift
//  Agenda Master
//
//  Created by Harun Gunaydin on 5/17/16.

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var agendaMasterImage: UIImageView!
    @IBOutlet weak var googleImage: UIImageView!
    @IBOutlet weak var appleImage: UIImageView!
    
    @IBAction func resetButtonDidTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "RESET", message: "Do you want to bring all deleted events?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .Default, handler: { (action) -> Void in
            
            print("Chose - YES")
            self.bringDeletedEventsBack()
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .Default, handler: { (action) in
           
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func bringDeletedEventsBack() {
        
        print("geldim")
        
        if let deletedItems = NSUserDefaults.standardUserDefaults().objectForKey("deletedItems") as? [String] {
            
            print("girdim")
            
            for event in deletedItems {
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "deletedEventForId_" + event)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "deletedItems")
            
            dispatch_async(dispatch_get_main_queue(), {
                
                eventTable.prepareForReload()
                eventTable.tableView.reloadData()
                
            })
            
            
        }
        
    }
    
    func changeStateOfAgendaMaster() {
        
        dispatch_async(dispatch_get_main_queue() , {
            
            if self.agendaMasterImage.alpha < 1 {
                self.agendaMasterImage.alpha = 1
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "Agenda Master_filtered")
            } else {
                self.agendaMasterImage.alpha = 0.15
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "Agenda Master_filtered")
            }
        
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            eventTable.prepareForReload()
            eventTable.tableView.reloadData()
            
        })
    }
    
    func changeStateOfGoogle() {
        
        dispatch_async(dispatch_get_main_queue() , {
            
            if self.googleImage.alpha < 1 {
                self.googleImage.alpha = 1
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "Google_filtered")
            } else {
                self.googleImage.alpha = 0.15
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "Google_filtered")
            }
            
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            eventTable.prepareForReload()
            eventTable.tableView.reloadData()
            
        })
    }
    
    func changeStateOfApple() {
        
        dispatch_async(dispatch_get_main_queue() , {
            
            if self.appleImage.alpha < 1 {
                self.appleImage.alpha = 1
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "Apple_filtered")
            } else {
                self.appleImage.alpha = 0.15
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "Apple_filtered")
            }
            
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            eventTable.prepareForReload()
            eventTable.tableView.reloadData()
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ( NSUserDefaults.standardUserDefaults().objectForKey("Agenda Master_filtered") as! Bool ) == true {
            self.agendaMasterImage.alpha = 1
        } else {
            self.agendaMasterImage.alpha = 0.15
        }
        
        if ( NSUserDefaults.standardUserDefaults().objectForKey("Google_filtered") as! Bool ) == true {
            self.googleImage.alpha = 1
        } else {
            self.googleImage.alpha = 0.15
        }
        
        if ( NSUserDefaults.standardUserDefaults().objectForKey("Apple_filtered") as! Bool ) == true {
            self.appleImage.alpha = 1
        } else {
            self.appleImage.alpha = 0.15
        }
        
        let agendaMasterImageTap = UITapGestureRecognizer(target: self, action: #selector(self.changeStateOfAgendaMaster))
        agendaMasterImage.addGestureRecognizer(agendaMasterImageTap)
        
        let googleImageTap = UITapGestureRecognizer(target: self, action: #selector(self.changeStateOfGoogle))
        googleImage.addGestureRecognizer(googleImageTap)
        
        let appleImageTap = UITapGestureRecognizer(target: self, action: #selector(self.changeStateOfApple))
        appleImage.addGestureRecognizer(appleImageTap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
