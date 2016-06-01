//
//  MapViewController.swift
//  Agenda Master
//
//  Created by Harun Gunaydin on 5/11/16.
//

import UIKit
import MapKit

var biggerRegion = MKCoordinateRegion()
var biggerAnnotation: MKAnnotation!

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.region = biggerRegion
        if biggerAnnotation != nil {
            mapView.addAnnotation(biggerAnnotation)
        } else {
            print("Error!!! - Annotation is nil")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
