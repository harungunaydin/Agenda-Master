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

class EventTableViewCell: FoldingCell {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var secondContainerView: RotatedView!
    @IBOutlet weak var mapButton: ZFRippleButton!
    
    
    var colors = [ UIColor.purpleColor() , UIColor.redColor() , UIColor.blackColor() , UIColor.greenColor() ]
    
    var colorIndex: Int = 0
    
    override func awakeFromNib() {
        
        
        print("asdf")
        super.awakeFromNib()
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        leftView.backgroundColor = colors[ colorIndex ]
        leftView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(self.changeColor)) )
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.nilFunction))
        singleTap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.switchToMapViewController))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
        
        doubleTap.requireGestureRecognizerToFail(singleTap)
        
        
        mapView.hidden = true
        
        mapButton.layer.cornerRadius = 13
        mapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mapButton.backgroundColor = UIColor.greenColor()
        mapButton.addTarget(self, action: #selector(self.setupMapView), forControlEvents: UIControlEvents.TouchUpInside)
        
        print("asdf2")
    }
    
    func nilFunction() {
        print("nilFunction")
    }
    
    func setupMapView() {
        
        mapButton.hidden = true
        mapView.hidden = false
        
        
    }
    
    func changeColor() {
        
        colorIndex = ( colorIndex + 1 ) % colors.count
        leftView.backgroundColor = colors[ colorIndex ]
    }
    
    func switchToMapViewController() {
        
        print("MapView has been double tapped")
        
    }
    
    override func closeAnimation(completion completion: CompletionHandler?) {
        
        print("closeAnimation")
        mapView.hidden = true
        super.closeAnimation(completion: completion)
        mapButton.hidden = false
        
    }
    
    override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval {
     
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
