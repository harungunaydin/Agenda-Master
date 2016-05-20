//
//  MainTableViewController.swift
//

import UIKit

class EventTableViewController: UITableViewController {
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    
    let refreshController: UIRefreshControl = UIRefreshControl()
    
    var cellHeights = [CGFloat]()
    
    func updateFilteredEventsArray() {
        
        filteredEvents = allEvents
        print("count = \(filteredEvents.count)")
        
        for _ in 0...filteredEvents.count {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    func refreshTable() {
        
        tableView.reloadData()
        
    }
    
    func pullEventsAndRefresh() {
        
        dispatch_async(dispatch_get_main_queue() ,  {
            
            AuthorizationsViewController().pullEvents()
            
        })
        
        
        dispatch_async(dispatch_get_main_queue() ,  {
            
            self.refreshTable()
            self.refreshController.endRefreshing()
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTableView = self.tableView
        
        self.refreshController.attributedTitle = NSAttributedString(string: "Pull to Update")
        self.refreshController.addTarget(nil, action: #selector(self.pullEventsAndRefresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.refreshController)
        
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.updateFilteredEventsArray()
            self.refreshTable()
        
        })
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            foldingCell.backgroundColor = UIColor.clearColor()
            
            if cellHeights[indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
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
        
        cell.tableView = self.tableView

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: Table vie delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
        
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
        
        if segue.identifier != "_BigMap" {
            return
        }
        
        if let destinationVC = segue.destinationViewController as? MapViewController {
            print("asdf")
            
            let indexPath = NSIndexPath(forItem: sender!.tag, inSection: 0)
            
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell {
                destinationVC.mapView = cell.mapView
            }
            
        } else {
            print("Error occured - prepareForSegue, EventTableViewController")
        }
        
    }
    
    
}
