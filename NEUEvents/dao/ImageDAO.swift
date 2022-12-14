//
//  ImageDAO.swift
//  NEUEvents
//
//  Created by tanay on 12/12/22.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

class ImageDAO {
    let dbRef: DatabaseReference
    let storageRef: StorageReference
    init() {
        dbRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    func deleteImage(_ imagePath: String) {
        // TODO: handle errors
        storageRef.child(imagePath).delete { error in
            if error != nil {
                print("---------------------------------------------------")
                print(error)
            }
        }
    }
    
    func getImageFromPath(_ imagePath: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        let image = storageRef.child(imagePath)
        image.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let data = data {
                completionHandler(UIImage(data: data))
            }
        }
    }
}
