//
//  AuthorizationsViewController.swift
//  AgendaMaster
//
//  Created by Harun Gunaydin on 4/28/16.
//  Copyright © 2016 Harun Gunaydin. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2
import ZFRippleButton
import EventKit
import StarWars

class AuthorizationsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "599334841741-tjcmvmd5lq8ovbnpk58pm4k041njh4do.apps.googleusercontent.com"
    
    private let service = GTLServiceCalendar()
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    
    @IBOutlet weak var agendaMasterButton: ZFRippleButton!
    @IBOutlet weak var googleButton: ZFRippleButton!
    @IBOutlet weak var appleButton: ZFRippleButton!
    
    var count: Int = 0
    
    func updateButtons() {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if ( defaults.objectForKey("isSignedInAgendaMaster") as! Bool ) == false {
                self.agendaMasterButton.setTitle("Sign In", forState: .Normal)
            } else {
                self.agendaMasterButton.setTitle("Sign Out", forState: .Normal)
            }
            
            if ( defaults.objectForKey("isSignedInGoogle") as! Bool ) == false {
                self.googleButton.setTitle("Sign In", forState: .Normal)
            } else {
                self.googleButton.setTitle("Sign Out", forState: .Normal)
            }
            
            if ( defaults.objectForKey("isSignedInApple") as! Bool ) == false {
                self.appleButton.setTitle("Sync", forState: .Normal)
            } else {
                self.appleButton.setTitle("Done", forState: .Normal)
                self.appleButton.userInteractionEnabled = false
            }
            
        })
    }
    
    @IBAction func updateBarButtonDidTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "UPDATE", message: "Do you want to update all calendars?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .Default, handler: { (action) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.pullEvents()
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                
                eventTable.prepareForReload()
                eventTable.tableView.reloadData()
                
            })
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.updateButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.updateButtons()
        
            self.agendaMasterButton.addTarget(nil, action: #selector(self.didTappedAgendaMasterButton) , forControlEvents: UIControlEvents.TouchUpInside)
            self.googleButton.addTarget(nil, action: #selector(self.didTappedGoogleButton) , forControlEvents: UIControlEvents.TouchUpInside)
            self.appleButton.addTarget(nil, action: #selector(self.didTappedAppleButton) , forControlEvents: UIControlEvents.TouchUpInside)
        
        })
        
    }
    
    func didTappedAgendaMasterButton() {
        
        if agendaMasterButton.titleLabel!.text == "Sign In" {
            performSegueWithIdentifier("_Login_Agenda_Master", sender: self)
        } else {
            
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInAgendaMaster")
            agendaMasterButton.setTitle("Sign In", forState: .Normal)
            NSUserDefaults.standardUserDefaults().removeObjectForKey("Agenda_Master_username")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("Agenda_Master_password")
            self.displayAlert("Successful", message: "You have successfully logged out from Agenda Master")

            
            var temp = [Event]()
            for event in allEvents {
                if event.source.name != "Agenda Master" {
                    temp.append(event)
                }
            }
            
            allEvents = temp
            temp.removeAll()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                eventTable.prepareForReload()
                eventTable.tableView.reloadData()
                
            })
            
        }
        
    }
    
    func didTappedGoogleButton() {
        
        if googleButton.titleLabel!.text == "Sign In" {
            self.linkWithGoogleCalendar()
        } else {
            service.authorizer = nil
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInGoogle")
            googleButton.setTitle("Sign In", forState: .Normal)
            self.displayAlert("Successful", message: "You have successfully logged out from Google")
            
            var temp = [Event]()
            for event in allEvents {
                if event.source.name != "Google" {
                    temp.append(event)
                }
            }
            
            allEvents = temp
            temp.removeAll()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                eventTable.prepareForReload()
                eventTable.tableView.reloadData()
                
            })
            
        }
        
        
    }
    
    func didTappedAppleButton() {
        
        if appleButton.titleLabel!.text == "Done" {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.displayAlert("Sync", message: "You have already sycned with your iPhone's calendar")
            })
            
        } else {
            self.linkWithIphoneCalendar()
        }
        
    }
    
    func linkWithGoogleCalendar() {
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName( kKeychainItemName, clientID: kClientID, clientSecret: nil) {
            service.authorizer = auth
            print("Google - service.authorizer = auth")
        }
        
        if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInGoogle") as! Bool ) == true {
            
            if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
                print("Error!!! - Already signed in")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInGoogle")
                service.authorizer = nil
                presentViewController( createAuthController(), animated: true, completion: nil )
            }
            
        } else {
            presentViewController( createAuthController(), animated: true, completion: nil )
        }
        
    }
    
    func linkWithIphoneCalendar() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event) {(granted, error) in
            
            if granted == false {
                defaults.setObject(false, forKey: "isSignedInApple")
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    defaults.setObject(true, forKey: "isSignedInApple")
                    self.updateButtons()
                    self.pullEvents()
                })
                
            }
    
        }
        
    }
    
    func checkCount() {
        self.count += 1
        print("count = \(self.count)")
        if self.count == 3 {
            print("---Finished Pulling Events---")
            print("#Events = \(allEvents.count)")
        
            
            dispatch_async(dispatch_get_main_queue(), {
                
                eventTable.prepareForReload()
                eventTable.tableView.reloadData()
                
            })
        }
    }
    
    func pullEvents() {
        
        print("---Started Pulling Events---")
        self.count = 0
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName( kKeychainItemName, clientID: kClientID, clientSecret: nil) {
            service.authorizer = auth
        }
        
        allEvents.removeAll()
        filteredEvents.removeAll()
        
        // Pull events from Google Calendar
        dispatch_async(dispatch_get_main_queue(), {
            
            if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInGoogle") as! Bool ) == true {
                print("Google SignIn - YES")
                self.fetchEventsFromGoogle()
            } else {
                print("Google SignIn - NO")
                self.checkCount()
            }

        })
        
        // Pull events from local calendar - iPhone Calendar
        dispatch_async(dispatch_get_main_queue(), {
            
            if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInApple") as! Bool ) == true {
                print("Apple SignIn - YES")
                self.fetchEventsFromIphoneCalendar()
            } else {
                print("Apple SignIn - NO")
                self.checkCount()
            }
            
        })
        
        // Pull events from Agenda Master Website
        dispatch_async(dispatch_get_main_queue(), {
            
            if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInAgendaMaster") as! Bool ) == true {
                print("Agenda Master SignIn - YES")
                self.fetchEventsFromAgendaMaster()
            } else {
                print("Agenda Master SignIn - NO")
                self.checkCount()
            }
            
        })
        
    }
    
    func fetchEventsFromAgendaMaster() {
        
        let username = NSUserDefaults.standardUserDefaults().objectForKey("Agenda_Master_username") as? String
        let password = NSUserDefaults.standardUserDefaults().objectForKey("Agenda_Master_password") as? String
        
        if username == nil || password == nil {
            print("Did not login to the Agenda Master")
            self.checkCount()
            return
        }
        
        let url:NSURL = NSURL(string: "http://clockblocked.us/~brian/resources/php/ios_get_tasks.php?username=" + username! + "&password=" + password! + "&ios_getcode=bb7427431a38")!
        
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let myQuery = urlSession.dataTaskWithURL(url, completionHandler: {
            data, response, error -> Void in
            
            if error != nil {
                print("error getting Agenda Master events")
                self.checkCount()
                return
            }
            
            if let content = data {
                do {
                    let jsonRes = try NSJSONSerialization.JSONObjectWithData(content, options: NSJSONReadingOptions.MutableContainers)
                    let objects = jsonRes["events"]!!
                    
                    print("Json convertion is successful and size => \(objects.count)")
                    
                    for i in 0 ..< objects.count {
                        
                        if let source = objects[i]["source"] as? String {
                            
                            if source != "native" {
                                continue
                            }
                            
                            let newEvent = Event()
                            
                            newEvent.objectId = "AGMASTER" + ( objects[i]["id"] as! String )
                            newEvent.name = objects[i]["title"] as? String
                            newEvent.summary = objects[i]["description"] as? String
                            
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "MMM dd, yyyy"
                            
                            let formatter2 = NSDateFormatter()
                            formatter2.dateFormat = "hh:mm a"
                            
                            if let startDate = objects[i]["startDate"] as? String {
                                newEvent.startDate = NSDate(timeIntervalSince1970: Double(startDate)!)
                                newEvent.startDateString = formatter.stringFromDate(newEvent.startDate)
                                newEvent.startHourString = formatter2.stringFromDate(newEvent.startDate)
                            }
                            
                            if let endDate = objects[i]["endDate"] as? String {
                                newEvent.endDate = NSDate(timeIntervalSince1970: Double(endDate)!)
                                newEvent.endDateString = formatter.stringFromDate(newEvent.endDate)
                                newEvent.endHourString = formatter2.stringFromDate(newEvent.endDate)
                            }
                            
                            newEvent.location = objects[i]["location"] as? String
                            
                            newEvent.source = sources[0]
                            
                            allEvents.append(newEvent)
                            
                        }
                        
                    }
                    
                    self.checkCount()
                    
                } catch {
                    self.checkCount()
                    print("Can not convert to JSON. Check you internet connection")
                }
            } else {
                self.checkCount()
                print("Check your internet connection")
            }
            
        })
        myQuery.resume()
        
    }
    
    func fetchEventsFromIphoneCalendar() {
        
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
            
            case .Authorized:
                
                let eventStore = EKEventStore()
                
                let events = eventStore.eventsMatchingPredicate( eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(timeIntervalSinceNow: 3*30*24*3600), calendars: [eventStore.defaultCalendarForNewEvents]) )
                print( eventStore.defaultCalendarForNewEvents.title )
                
                for event in events {
                    
                    let newEvent = Event()
                    
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "MMM dd, yyyy"
                    
                    let formatter2 = NSDateFormatter()
                    formatter2.dateFormat = "hh:mm a"
                    
                    newEvent.startDate = event.startDate
                    newEvent.endDate = event.endDate
                    
                    if newEvent.startDate != nil {
                        newEvent.startDateString = formatter.stringFromDate(newEvent.startDate)
                        newEvent.startHourString = formatter2.stringFromDate(newEvent.startDate)
                    }
                    
                    if newEvent.endDate != nil {
                        newEvent.endDateString = formatter.stringFromDate(newEvent.endDate)
                        newEvent.endHourString = formatter2.stringFromDate(newEvent.endDate)
                    }
                    
                    
                    newEvent.objectId = event.eventIdentifier
                    newEvent.location = event.location
                    newEvent.source = sources[2] // Source: Apple
                    
                    if let start = newEvent.startDate {
                        if let end = newEvent.endDate {
                            newEvent.duration = end.timeIntervalSinceDate(start)
                        }
                    }
                    
                    newEvent.name = event.title
                    newEvent.summary = event.notes
                    
                    allEvents.append(newEvent)
                    
                }
                self.checkCount()
                break
            
            default:
                
                self.checkCount()
                break
        }
        
    }
    
    func fetchEventsFromGoogle() {
        
        if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
        } else {
            print("Error!!! - Signed in but could not authorize. fetchEventsFromGoogle - AuthorizationsViewController")
            googleButton.setTitle("Sign In", forState: .Normal)
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInGoogle")
            self.checkCount()
            return
        }
        
        print("fetchEventsFromGoogle")
        
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 100
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone() )
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        
        service.executeQuery(query) { (ticket, object, error) in
            
            if error != nil {
                self.dismissViewControllerAnimated(true, completion: {
                    print("Please check your internet connection")
                })
                return
            }
            
            
            if let events = object.items() as? [GTLCalendarEvent] {
                
                for event in events {
                    
                    let newEvent = Event()
                    
                    newEvent.name = event.summary
                    
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "MMM dd, yyyy"
                    
                    let formatter2 = NSDateFormatter()
                    formatter2.dateFormat = "hh:mm a"
                    
                    if event.start != nil && event.start.dateTime != nil {
                        newEvent.startDate = event.start.dateTime.date
                        newEvent.startDateString = formatter.stringFromDate(newEvent.startDate)
                        newEvent.startHourString = formatter2.stringFromDate(newEvent.startDate)
                    }
                    
                    if event.end != nil && event.end.dateTime != nil {
                        newEvent.endDate = event.end.dateTime.date
                        newEvent.endDateString = formatter.stringFromDate(newEvent.endDate)
                        newEvent.endHourString = formatter2.stringFromDate(newEvent.endDate)
                    }
                    
                    if newEvent.startDate != nil && newEvent.endDate != nil {
                        newEvent.duration = newEvent.endDate.timeIntervalSinceDate(newEvent.startDate)
                    }
                    newEvent.source = sources[1]
                    newEvent.summary = event.descriptionProperty
                    newEvent.location = event.location
                    newEvent.objectId = event.identifier
                    
                    allEvents.append(newEvent)
                }
            }
            
            print("fetchEventsFromGoogle - Done")
            self.checkCount()
            
        }
        
    }
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch( scope: scopeString, clientID: kClientID, clientSecret: nil, keychainItemName: kKeychainItemName, delegate: self, finishedSelector: #selector(self.viewController(_:finishedWithAuth:error:)) )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController, finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            self.displayAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isSignedInGoogle")
        dismissViewControllerAnimated(true, completion: nil)
        
        self.pullEvents()
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        destination.transitioningDelegate = self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationControllerForDismissedController")
        return StarWarsGLAnimator()
    }
    
}