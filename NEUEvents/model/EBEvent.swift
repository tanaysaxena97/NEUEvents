//
//  EBEvent.swift
//  NEUEvents
//
//  Created by tanay on 12/14/22.
//

import Foundation

class EBEvent: Codable {
    var id: Int
    var name: String
    var summary: String
    var startDate: String
    var ticketURL: String
    var imageURL: String
    var address: String
    
    init(id: Int, name: String, summary: String, startDate: String, ticketURL: String, imageURL: String, address: String) {
        self.id = id
        self.name = name
        self.summary = summary
        self.startDate = startDate
        self.ticketURL = ticketURL
        self.imageURL = imageURL
        self.address = address
    }
    
    func getSearchText() -> String {
        "\(self.name.lowercased()) \(self.summary.lowercased()) \(self.startDate) \(self.address.lowercased())"
    }
}

class EBEvents: Codable {
    var events: [EBEvent]
    internal init(events: [EBEvent]) {
        self.events = events
    }
}
