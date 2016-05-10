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
    var endDate: NSDate!
    var summary: String!
    var duration: Double!
    var location: String!
    var source: EventSource!
    
    init() {
        name = ""
        summary = ""
        duration = -1
        location = ""
        
    }
    
    init(name: String , startDate: NSDate , endDate: NSDate , summary: String , duration: Double , location: String , source: EventSource) {
        
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.duration = duration
        self.source = source
        self.location = location
    }
    
    
}