//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import UIKit
import MapKit
import ZFRippleButton

var cellLeftViewColors = [ UIColor.purpleColor() , UIColor.redColor() , UIColor.blackColor() , UIColor.greenColor() ]

class EventTableViewCell: FoldingCell {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel2: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var secondContainerView: RotatedView!
    @IBOutlet weak var mapButton: ZFRippleButton!
    @IBOutlet weak var biggerMapButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
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
        
    }
    
    func deleteEvent() {
        
        print("deleteEvent()")
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "deletedEventForId_" + self.objectId )
        
        filteredEvents.removeAtIndex(row)
        
        eventTable.tableView.reloadData()
        
    }
    
    func setupBiggerMapView() {
        
        biggerRegion = self.mapView.region
        if self.mapView.annotations.count > 0 {
            biggerAnnotation = self.mapView.annotations[0]
        }
        
    }
    
    
    func setupMapView() {
        
        if shouldHideMapButton == true {
            fatalError("YO WTF??!!!?? - setupMapView() , EventTableViewCell.swift")
        }
        
        mapButton.hidden = true
        biggerMapButton.hidden = false
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(filteredEvents[row].location) { (placemarks, error) in
            
            if let placemarks = placemarks {
                
                if placemarks.count > 0 {
                    
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    
                    var region: MKCoordinateRegion = self.mapView.region
                    region.center = (placemark.location?.coordinate)!
                    region.span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(placemark)
                }
                
            }
            
            self.mapView.hidden = false
            
        }
        
        
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
