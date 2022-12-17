//
//  Event.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import Foundation

class Event: Codable {

    var id: String
    var name: String
    var description: String
    var startTime: String
    var organiserEmail: String
    var imagePaths: [String]
    
    init(id: String, name: String, description: String, startTime: String, organiserEmail: String, imagePaths: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.startTime = startTime
        self.organiserEmail = organiserEmail
        self.imagePaths = imagePaths
    }
    
    func getStorableObj() -> [String: Any] {
        [
            "id": id,
            "name": name,
            "description": description,
            "startTime": startTime,
            "organiserEmail": organiserEmail,
            "imagePaths": imagePaths
        ]
    }
    
    convenience init(_ dict: [String: Any]) {
        self.init(id: dict["id"] as! String, name: dict["name"] as! String, description: dict["description"] as! String,
                  startTime: dict["startTime"] as! String , organiserEmail: dict["organiserEmail"] as! String, imagePaths: dict["imagePaths"] as! [String])
    }
    
    func searchString() -> String {
        "\(name.lowercased()) \(description.lowercased()) \(startTime)"
    }
    
    func getCellText() -> String {
        """
        
        Name: \(name)
        Date: \(startTime)
        """
    }
}
