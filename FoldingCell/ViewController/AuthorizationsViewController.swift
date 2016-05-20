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

class AuthorizationsViewController: UIViewController {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "599334841741-tjcmvmd5lq8ovbnpk58pm4k041njh4do.apps.googleusercontent.com"
    
    private let service = GTLServiceCalendar()
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    
    @IBOutlet weak var agendaMasterButton: ZFRippleButton!
    @IBOutlet weak var googleButton: ZFRippleButton!
    @IBOutlet weak var appleButton: ZFRippleButton!
    @IBOutlet weak var facebookButton: ZFRippleButton!
    
    var count: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if ( defaults.objectForKey("isSignedInAgendaMaster") as! Bool ) == false {
            agendaMasterButton.setTitle("Sign In", forState: .Normal)
        } else {
            agendaMasterButton.setTitle("Sign Out", forState: .Normal)
        }
        
        if ( defaults.objectForKey("isSignedInGoogle") as! Bool ) == false {
            googleButton.setTitle("Sign In", forState: .Normal)
        } else {
            googleButton.setTitle("Sign Out", forState: .Normal)
        }
        
        if ( defaults.objectForKey("isSignedInApple") as! Bool ) == false {
            appleButton.setTitle("Sign In", forState: .Normal)
        } else {
            appleButton.hidden = true
        }
        
        if ( defaults.objectForKey("isSignedInFacebook") as! Bool ) == false {
            facebookButton.setTitle("Sign In", forState: .Normal)
        } else {
            facebookButton.setTitle("Sign Out", forState: .Normal)
        }
        
        
        agendaMasterButton.addTarget(nil, action: #selector(self.didTappedAgendaMasterButton) , forControlEvents: UIControlEvents.TouchUpInside)
        googleButton.addTarget(nil, action: #selector(self.didTappedGoogleButton) , forControlEvents: UIControlEvents.TouchUpInside)
        appleButton.addTarget(nil, action: #selector(self.didTappedAppleButton) , forControlEvents: UIControlEvents.TouchUpInside)
        facebookButton.addTarget(nil, action: #selector(self.didTappedFacebookButton) , forControlEvents: UIControlEvents.TouchUpInside)
        
        
    }
    
    func didTappedAgendaMasterButton() {
        
    }
    
    func didTappedGoogleButton() {
        
        if googleButton.titleLabel!.text == "Sign In" {
            self.linkWithGoogleCalendar()
        } else {
            service.authorizer = nil
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInGoogle")
            googleButton.setTitle("Sign In", forState: .Normal)
            self.displayAlert("Successfull", message: "You have successfully logged out from Google")
        }
        
        
    }
    
    func didTappedAppleButton() {
        self.linkWithIphoneCalendar()
    }
    
    func didTappedFacebookButton() {
        
    }
    
    func linkWithGoogleCalendar() {
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName( kKeychainItemName, clientID: kClientID, clientSecret: nil) {
            service.authorizer = auth
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if ( defaults.objectForKey("isSignedInGoogle") as! Bool ) == true {
            
            if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
                print("Error!!! - Already signed in")
            } else {
                defaults.setObject(false, forKey: "isSignedInGoogle")
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
                    self.appleButton.hidden = true
                    defaults.setObject(true, forKey: "isSignedInApple")
                })
                
            }
    
        }
        
    }
    
    func linkWithFacebookCalendar() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func checkCount() {
        count += 1
        if count == 2 {
            print("---Finished Pulling Events---")
            eventTableView.reloadData()
        }
    }
    
    func pullEvents() {
        
        
        print("---Started Pulling Events---")
        count = 0
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName( kKeychainItemName, clientID: kClientID, clientSecret: nil) {
            service.authorizer = auth
        }
        
        allEvents.removeAll()
        filteredEvents.removeAll()
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInGoogle") as! Bool ) == true {
                self.fetchEventsFromGoogle()
            }

        })
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if ( NSUserDefaults.standardUserDefaults().objectForKey("isSignedInApple") as! Bool ) == true {
                self.fetchEventsFromIphoneCalendar()
            }
            
        })
        
    }
    
    func fetchEventsFromIphoneCalendar() {
        
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
            
            case .Authorized:
                
                let eventStore = EKEventStore()
                
                let events = eventStore.eventsMatchingPredicate( eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(timeIntervalSinceNow: +30*24*3600), calendars: [eventStore.defaultCalendarForNewEvents]) )
                
                for event in events {
                    
                    let newEvent = Event()
                    newEvent.startDate = event.startDate
                    newEvent.endDate = event.endDate
                    newEvent.objectId = event.eventIdentifier
                    newEvent.location = event.location
                    newEvent.source = sources[2] // Source: Apple
                    
                    if let start = newEvent.startDate {
                        if let end = newEvent.endDate {
                            newEvent.duration = end.timeIntervalSinceDate(start)
                        }
                    }
                    
                    newEvent.name = event.title
                    newEvent.summary = event.description
                    
                    allEvents.append(newEvent)
                    
                }
                
                count += 1
                
                break
            
            
            default: return
        }
        
    }
    
    func fetchEventsFromGoogle() {
        
        if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            
        } else {
            print("Error!!! - Signed in but could not authorize. fetchEventsFromGoogle - AuthorizationsViewController")
            googleButton.setTitle("Sign In", forState: .Normal)
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isSignedInGoogle")
            checkCount()
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
                    self.displayAlert("Error", message: "Please check your internet connection")
                })
                return
            }
            
            if let events = object.items() as? [GTLCalendarEvent] {
                
                for event in events {
                    
                    let newEvent = Event()
                    
                    newEvent.name = event.summary
                    
                    if let start = event.start {
                        if let start = start.date {
                            newEvent.startDate = start.date
                        }
                    }
                    
                    if event.start != nil && event.start.date != nil {
                        newEvent.startDate = event.start.date.date
                    } else {
                        newEvent.startDate = nil
                    }
                    
                    if event.end != nil && event.end.date != nil {
                        newEvent.endDate = event.end.date.date
                    } else {
                        newEvent.endDate = nil
                    }
                    
                    if newEvent.startDate != nil && newEvent.endDate != nil {
                        newEvent.duration = newEvent.endDate.timeIntervalSinceDate(newEvent.startDate)
                    }
                    newEvent.source = sources[0]
                    newEvent.summary = event.descriptionProperty
                    newEvent.location = event.location
                    newEvent.objectId = event.identifier
                    
                    allEvents.append(newEvent)
                }
            }
            
            print("fetchEventsFromGoogle - Done")
            self.count += 1
            
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
        dismissViewControllerAnimated(true, completion: nil)
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isSignedInGoogle")
        googleButton.setTitle("Sign Out", forState: .Normal)
        
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
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}