//
//  EventDAO.swift
//  NEUEvents
//
//  Created by tanay on 11/25/22.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

class EventDAO {
    let dbRef: DatabaseReference
    let storageRef: StorageReference
    init() {
        dbRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    func saveEvent(_ event: Event, images: [UIImage] = []) {
        // TODO: delete previous object if exists along with previous images.
        var imagePaths: [String] = []
        for image in images {
            let imagePath = "images/\(UUID().uuidString).png"
            imagePaths.append(imagePath)
            let data = getDataFromImage(resizeImage(image))
            let fileRef = storageRef.child(imagePath)
            fileRef.putData(data) { metadata, error in}
        }
        event.organiserEmail = EventDAO.getSignedUserEmail() ?? event.organiserEmail
        event.imagePaths = imagePaths
        dbRef.child("events/\(event.id)").setValue(event.getStorableObj())
    }
    
    func getEventById(_ id: String, onDataRetrieve : @escaping (DataSnapshot) -> Void) {
        dbRef.child("events/\(id)").observeSingleEvent(of: .value, with: onDataRetrieve)
    }
    
    func getAllEvents(onDataRetrieve : @escaping (DataSnapshot) -> Void) {
        dbRef.child("events/").observeSingleEvent(of: .value, with: onDataRetrieve)
    }
    
    static func getSignedUserEmail() -> String? {
        GIDSignIn.sharedInstance.currentUser?.profile?.email
    }
}
