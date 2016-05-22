//
//  MainTableViewController.swift
//

import UIKit
import MapKit
import StarWars

class EventTableViewController: UITableViewController {

    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    
    let eventLimit = 100
    
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        eventTable = self
        
        self.transitioningDelegate = self
        
        AuthorizationsViewController().pullEvents()
        
    }
    
    func didTappedAuthButton() {
        
        print("didTappedAuthButton")
        
        let authVC = self.storyboard!.instantiateViewControllerWithIdentifier("AuthorizationsViewController") as! AuthorizationsViewController
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 1
        transition.timingFunction = timeFunc
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController!.pushViewController(authVC, animated: true)
        
    }
    
    func cmp( a : Event , b : Event ) -> Bool {
        if b.startDate == nil {
            return false
        } else if a.startDate == nil {
            return true
        }
        
        let x = a.startDate.timeIntervalSince1970
        let y = b.startDate.timeIntervalSince1970
        
        if x < y {
            return true
        } else if x > y {
            return false
        } else {
            
            if b.endDate == nil {
                return false
            } else if a.endDate == nil {
                return true
            }
            
            return a.endDate.timeIntervalSince1970 < b.endDate.timeIntervalSince1970
        }
    }
    
    func prepareForReload() {
        
        filteredEvents.removeAll()
        for event in allEvents {
            
            if NSUserDefaults.standardUserDefaults().objectForKey( event.source.name + "_filtered" ) as! Bool {
                
                if let isDeleted = NSUserDefaults.standardUserDefaults().objectForKey("deletedEventForId_" + event.objectId) as? Bool {
                    
                    if isDeleted == false {
                        filteredEvents.append(event)
                    }
                    
                } else {
                    filteredEvents.append(event)
                }
                
            }
            
            // EVENT LIMIT
            if filteredEvents.count == self.eventLimit {
                break
            }
            
        }
        
        filteredEvents = filteredEvents.sort(cmp)
        
        cellHeights.removeAll()
        for _ in 0...filteredEvents.count {
            cellHeights.append(kCloseCellHeight)
        }
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("size of the table => \(filteredEvents.count)")
        return filteredEvents.count
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            foldingCell.backgroundColor = UIColor.clearColor()
            
            if cellHeights[indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion: nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FoldingCell", forIndexPath: indexPath) as! EventTableViewCell
        
        cell.row = indexPath.row
        let row = cell.row
        
        cell.biggerMapButton.tag = row
        
        let event = filteredEvents[row]
        
        cell.objectId = event.objectId
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // set LeftView backgroundColor
        if let ind = defaults.objectForKey("colorIndexForCellForId_" + cell.objectId) as? Int {
            cell.leftView.backgroundColor = cellLeftViewColors[ind]
        } else {
            defaults.setObject(0, forKey: "colorIndexForCellForId_" + cell.objectId)
            cell.leftView.backgroundColor = cellLeftViewColors[0]
        }
        
        cell.eventNameLabel.text = event.name
        cell.eventNameLabel2.text = event.name
        cell.textView.text = event.summary
        
        if let start = event.startDate {
            cell.startDateLabel.text = "\(start)"
        }
        
        if let end = event.endDate {
            cell.endDateLabel.text = "\(end)"
        }
        
        if event.location == nil || event.location.characters.count < 5 {
            cell.mapButton.hidden = true
            cell.shouldHideMapButton = true
            cell.noLocationLabel.hidden = false
        } else {
            
            cell.shouldHideMapButton = false
            cell.noLocationLabel.hidden = true
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: Table vie delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
        
        cell.mapButton.hidden = cell.shouldHideMapButton
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        destination.transitioningDelegate = self
    }
    
}

extension EventTableViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationControllerForDismissedController")
        return StarWarsGLAnimator()
    }
    
}
