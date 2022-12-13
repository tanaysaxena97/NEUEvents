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
    
    func getImageFromPath(_ imagePath: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
//        if(imageCache.objectForKey(imagePath) != nil) {
//            completionHandler(imageCache.objectForKey(imagePath))
//        }
            let image = storageRef.child(imagePath)
            image.getData(maxSize: 50 * 1024) { data, error in
                if let data = data {
                    completionHandler(UIImage(data: data))
                    // add image to cache
//                    imageCache.setValue(UIImage(data: data), forKey: imagePath)
                }
            }
        
    }
}
