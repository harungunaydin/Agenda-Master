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
    
    var row: Int!
    var objectId: String!
    
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
        
    }
    
    func deleteEvent() {
        
        print("deleteEvent()")
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "deletedCellForId_" + self.objectId )
        
        allEvents.removeAtIndex(row)
        
        //Somehow Refresh the Table
        
        
        
    }
    
    
    func setupMapView() {
        
        mapButton.hidden = true
        biggerMapButton.hidden = false
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(filteredEvents[row].location) { (placemarks, error) in
            
            if let placemarks = placemarks {
                
                if placemarks.count > 0 {
                    
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    
                    var region: MKCoordinateRegion = self.mapView.region
                    region.center = (placemark.location?.coordinate)!
                //    region.span.longitudeDelta /= 8.0
                //    region.span.latitudeDelta /= 8.0
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(placemark)
                    
                }
                
                
            }
            
        }
        
        mapView.hidden = false
        
    }
    
    func changeColor() {
        
        if self.objectId == nil {
            print("objectId is nill - changeColor(), EventTableViewCell")
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
        super.closeAnimation(completion: completion)
        mapButton.hidden = false
        biggerMapButton.hidden = true
        
    }
    
    override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval {
     
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
