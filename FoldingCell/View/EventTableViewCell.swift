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
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var secondContainerView: RotatedView!
    @IBOutlet weak var mapButton: ZFRippleButton!
    @IBOutlet weak var biggerMapButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    
    var row: Int!
    var objectId: String!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        leftView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(self.changeColor)) )
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: nil)
        singleTap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(singleTap)
 
        mapView.hidden = true
        
        mapButton.layer.cornerRadius = 13
        mapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mapButton.backgroundColor = UIColor.greenColor()
        mapButton.addTarget(self, action: #selector(self.setupMapView), forControlEvents: UIControlEvents.TouchUpInside)
        
        biggerMapButton.addTarget(self, action: #selector(self.switchToMapViewController), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func deleteEvent() {
        
        if row == nil {
            return
        }
        
        allEvents.removeAtIndex(row)
        
        
    }
    
    
    func setupMapView() {
        
        mapButton.hidden = true
        mapView.hidden = false
        
    }
    
    func changeColor() {
        
        if self.objectId == nil {
            print("objectId is nill - changeColor(), EventTableViewCell")
            return
        }
        
        if let ind = NSUserDefaults.standardUserDefaults().objectForKey("colorIndexForCellForId_" + self.objectId) as? Int {
            
            NSUserDefaults.standardUserDefaults().setObject( (ind+1) % cellLeftViewColors.count , forKey: "colorIndexForCellForId_" + self.objectId)
            leftView.backgroundColor = cellLeftViewColors[ (ind+1) % cellLeftViewColors.count ]
            
        } else {
            print("An error occured - changeColor(), EventTableViewCell")
        }
    }
    
    func switchToMapViewController() {
        
        print("Implement this")
        
    }
    
    override func closeAnimation(completion completion: CompletionHandler?) {
        
        mapView.hidden = true
        super.closeAnimation(completion: completion)
        mapButton.hidden = false
        
    }
    
    override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval {
     
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
