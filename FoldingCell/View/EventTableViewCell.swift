//
//  EventTableViewCell.swift
//  Agenda Master
//
//

import UIKit
import MapKit
import ZFRippleButton

var cellLeftViewColors = [ UIColor.purpleColor() , UIColor.redColor() , UIColor.blackColor() , UIColor.greenColor() ]

class EventTableViewCell: FoldingCell {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel2: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateLabel2: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateLabel2: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var secondContainerView: RotatedView!
    @IBOutlet weak var mapButton: ZFRippleButton!
    @IBOutlet weak var biggerMapButton: UIButton!
    @IBOutlet weak var trashButton: ZFRippleButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContrainerView: RotatedView!
    @IBOutlet weak var noLocationLabel: UILabel!
    
    
    var row: Int!
    var objectId: String!
    var shouldHideMapButton: Bool!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        leftView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(self.changeColor)) )
        
        mapView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: nil) )
        mapView.hidden = true
        
        mapButton.layer.cornerRadius = 13
        mapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mapButton.backgroundColor = UIColor.greenColor()
        mapButton.addTarget(self, action: #selector(self.setupMapView), forControlEvents: UIControlEvents.TouchUpInside)
        
        biggerMapButton.hidden = true
        biggerMapButton.addTarget(self, action: #selector(self.setupBiggerMapView), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.trashButton.addTarget(self, action: #selector(self.deleteEvent), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func deleteEvent() {
        
        let alert = UIAlertController(title: "Trash", message: "Delete Event?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .Default, handler: { (action) -> Void in
            
            if let items = NSUserDefaults.standardUserDefaults().objectForKey("deletedItems") as? [String] {
                
                var deletedItems = items
                deletedItems.append(self.objectId)
                NSUserDefaults.standardUserDefaults().setObject(deletedItems, forKey: "deletedItems")
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "deletedEventForId_" + self.objectId )
                
                dispatch_async(dispatch_get_main_queue(), {
                    eventTable.prepareForReload()
                    eventTable.tableView.reloadData()
                })
                
            } else {
                var deletedItems = [String]()
                deletedItems.append(self.objectId)
                NSUserDefaults.standardUserDefaults().setObject(deletedItems, forKey: "deletedItems")
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "deletedEventForId_" + self.objectId )
                
                dispatch_async(dispatch_get_main_queue(), {
                    eventTable.prepareForReload()
                    eventTable.tableView.reloadData()
                })
                
            }
            
            eventTable.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .Default, handler: { (action) in
            
            eventTable.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        eventTable.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func setupBiggerMapView() {
        
        biggerRegion = self.mapView.region
        if self.mapView.annotations.count > 0 {
            biggerAnnotation = self.mapView.annotations[0]
        }
        
    }
    
    func geocodeAddressing(address: String , count: Int) {
        
        let geocoder = CLGeocoder()
        
        print("location = \(address) count = \(count)")
        
        geocoder.geocodeAddressString(filteredEvents[row].location) { (placemarks, error) in
            
            if let placemarks = placemarks {
                
                if placemarks.count > 0 {
                    
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    
                    var region: MKCoordinateRegion = self.mapView.region
                    region.center = (placemark.location?.coordinate)!
                    region.span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(placemark)
                    
                } else if count < 2 {
                    self.geocodeAddressing(address, count: count + 1)
                    return
                }
                
            } else if count < 2 {
                self.geocodeAddressing(address, count: count + 1)
                return
            }
            
            self.mapView.hidden = false
            
        }
        
    }
    
    func setupMapView() {
        
        if shouldHideMapButton == true {
            fatalError("setupMapView() , EventTableViewCell.swift")
        }
        
        mapButton.hidden = true
        biggerMapButton.hidden = false
        
        self.geocodeAddressing(filteredEvents[row].location, count: 0)
        
    }
    
    func changeColor() {
        
        if self.objectId == nil {
            print("objectId is nil - changeColor(), EventTableViewCell")
            return
        }
        
        if let ind = NSUserDefaults.standardUserDefaults().objectForKey("colorIndexForCellForId_" + self.objectId) as? Int {
            
            let index = (ind + 1) % cellLeftViewColors.count
            NSUserDefaults.standardUserDefaults().setObject( index , forKey: "colorIndexForCellForId_" + self.objectId)
            leftView.backgroundColor = cellLeftViewColors[index]
            
        } else {
            print("An error occured - changeColor(), EventTableViewCell")
        }
    }
    
    override func closeAnimation(completion completion: CompletionHandler?) {
        
        mapView.hidden = true
        biggerMapButton.hidden = true
        super.closeAnimation(completion: completion)
        mapButton.hidden = self.shouldHideMapButton
        
    }
    
    override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval {
     
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
