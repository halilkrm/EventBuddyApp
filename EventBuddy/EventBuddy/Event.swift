//
//  Event.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 15.10.2025.
//

import Foundation

struct Event: Identifiable, Codable {
    var id: String?      
    var title: String
    var date: Date
    var description: String
    var location : String
    var createdById : String
    
    
    var participants: [String: String]
    
    init(id: String?, title: String, date: Date, description: String, location: String, createdById: String, participants: [String: String]) {
            self.id = id
            self.title = title
            self.date = date
            self.description = description
            self.location = location
            self.createdById = createdById
            self.participants = participants
        }
    
}
