//
//  Event.swift
//  AgendaMaster
//
//  Created by Harun Gunaydin on 4/28/16.
//  Copyright © 2016 Harun Gunaydin. All rights reserved.
//

import Foundation

class Event {
    
    var name: String!
    var startDate: NSDate!
    var startDateString: String!
    var startHourString: String!
    var endDate: NSDate!
    var endDateString: String!
    var endHourString: String!
    var summary: String!
    var duration: Double!
    var location: String!
    var objectId: String!
    var source: EventSource!
    
    init() {
        self.name = ""
        self.startDate = nil
        self.startDateString = ""
        self.startHourString = ""
        self.endDate = nil
        self.endDateString = ""
        self.endHourString = ""
        self.summary = ""
        self.duration = -1
        self.location = ""
        self.objectId = ""
        
    }
    
    
}