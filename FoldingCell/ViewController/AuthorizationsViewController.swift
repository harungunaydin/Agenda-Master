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

class AuthorizationsViewController: UIViewController {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "599334841741-tjcmvmd5lq8ovbnpk58pm4k041njh4do.apps.googleusercontent.com"
    
    private let service = GTLServiceCalendar()
    private let scopes = [kGTLAuthScopeCalendarReadonly]

    @IBOutlet weak var googleButton: UIImageView!
    @IBOutlet weak var appleButton: UIImageView!
    @IBOutlet weak var facebookButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(self.linkWithGoogleCalendar) )
        googleButton.addGestureRecognizer(googleTap)
        
        let appleTap = UITapGestureRecognizer(target: self, action: #selector(self.linkWithIphoneCalendar) )
        appleButton.addGestureRecognizer(appleTap)
        
        let facebookTap = UITapGestureRecognizer(target: self, action: #selector(self.linkWithFacebookCalendar) )
        facebookButton.addGestureRecognizer(facebookTap)
        
        
    }
    
    func linkWithGoogleCalendar() {
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName( kKeychainItemName, clientID: kClientID, clientSecret: nil) {
            service.authorizer = auth
        }
        
        if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            self.displayAlert("Already Linked", message: "This account is already linked with Google Calendar. Fetching new Events...")
            self.fetchEventsFromGoogle()
        } else {
            presentViewController( createAuthController(), animated: true, completion: nil )
        }
        
    }
    
    func linkWithIphoneCalendar() {
        
    }
    
    func linkWithFacebookCalendar() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func fetchEventsFromGoogle() {
        
        print("fetchEventsFromGoogle")
        
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 100
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone() )
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        
        allEvents.removeAll()
        
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
                
                // Delete this line when the time comes
                filteredEvents = allEvents
            }
            
            print("fetchEventsFromGoogle - Done")
            
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
            displayAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
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
