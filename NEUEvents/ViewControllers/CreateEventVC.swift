//
//  CreateEventVC.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import UIKit
import PhotosUI
import GoogleSignIn

class CreateEventVC: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pickerConfig = PHPickerConfiguration()
    var images: [UIImage] = []
    var eventStartDate: Date?
    var readOnly = false
    
    @IBOutlet weak var nameInputView: UITextField!
    @IBOutlet weak var descriptionInputView: UITextView!
    
    @IBOutlet weak var pickImagesButton: UIButton!
    @IBOutlet weak var eventStartDateInputView: UIDatePicker!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // image collection
        
//        imageCollectionView.delegate = self
//        imageCollectionView.dataSource = self
//
//        pickerConfig.filter = .images
//        pickerConfig.selectionLimit = 4
//
//        eventStartDateInputView.addTarget(self, action: #selector(handleEvnetStartDateChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if readOnly {
            disableButton(submitButton)
            disableButton(pickImagesButton)
            nameInputView.isUserInteractionEnabled = false
            descriptionInputView.isUserInteractionEnabled = false
            eventStartDateInputView.isUserInteractionEnabled = false
        }
    }
    
    func setEvent(_ eventId: String) {
        EventDAO().getEventById(eventId) { dataSnapshot in
            let event = Event(dataSnapshot.value as! [String: Any])
            self.nameInputView.text = event.name
            self.descriptionInputView.text = event.description
        }
    }
    
    func disableButton(_ button: UIButton) {
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.isEnabled = false
    }
    @objc func handleEvnetStartDateChanged() {
        eventStartDate = eventStartDateInputView.date
    }
    
    @IBAction func pickImagesTapped(_ sender: Any) {
        let picker = PHPickerViewController(configuration: pickerConfig)
        picker.delegate = self
        self.navigationController?.pushViewController(picker, animated: true)
//        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // remove picker from stack
        self.navigationController?.popViewController(animated: true)
        if results.count > 0 {
            images.removeAll()
        }
        for pickerResult in results {
            if pickerResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
                pickerResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, error in
                    if let error = error {
                        print("Can't load image: \(error.localizedDescription)")
                    }
                    else if let image = newImage as? UIImage, let safeSelf = self {
                      // Add new image and pass it back to the main view
                        DispatchQueue.main.async {
                            safeSelf.images.append(image)
                            safeSelf.imageCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // image collection config
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = resizeImage(images[indexPath.row], size: imageCollectionView.visibleSize)
        return cell
    }
    
    func validateForm() -> Event? {
        let nameOpt = nameInputView.text
        let descriptionOpt = descriptionInputView.text
        guard validateFormText(nameOpt), let name = nameOpt else {
            showErrorAlert(self, "Name of the event cannot be empty.")
            return nil
        }
        guard validateFormText(descriptionOpt), let description = descriptionOpt else {
            showErrorAlert(self, "Description of the event cannot be empty.")
            return nil
        }
        guard let eventStartDate = eventStartDate else {
            showErrorAlert(self, "Please select start date and time.")
            return nil
        }
        guard eventStartDate > Date() else {
            showErrorAlert(self, "Event start date and time cannot be before today.")
            return nil
        }
        return Event(id: UUID().uuidString,name: name, description: description, startTime: getFormattedDateString(eventStartDate), organiserEmail: "\(UUID().uuidString)@gmail.com", imagePaths: [])
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if let event = validateForm() {
            let eventDAO = EventDAO()
            eventDAO.saveEvent(event, images: images)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CreateEventVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        imageCollectionView.visibleSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
