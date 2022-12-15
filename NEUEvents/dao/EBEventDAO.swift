//
//  EBEventDAO.swift
//  NEUEvents
//
//  Created by tanay on 12/14/22.
//

import Foundation

class EBEventDAO {
    static var events: EBEvents?
    
    init() {
        if EBEventDAO.events == nil {
            guard let filepath = Bundle.main.url(forResource: "events", withExtension: "json") else {
                print("--------- File not found ------------")
                return
            }
            do {
                let data = try Data(contentsOf: filepath, options: .mappedIfSafe)
                EBEventDAO.events = try JSONDecoder().decode(EBEvents.self, from: data)
            } catch {
                print(error)
                return
            }
        }
    }
}
