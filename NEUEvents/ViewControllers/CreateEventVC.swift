//
//  CreateEventVC.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import UIKit
import PhotosUI
import GoogleSignIn
import EventKit
import EventKitUI


class CreateEventVC: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
    }
    
    
    var pickerConfig = PHPickerConfiguration()
    var images: [UIImage] = []
    var eventStartDate: Date?
    var readOnly = false
    let store = EKEventStore()
    var event: Event?
    
    @IBOutlet weak var nameInputView: UITextField!
    @IBOutlet weak var descriptionInputView: UITextView!
    
    @IBOutlet weak var pickImagesButton: UIButton!
    @IBOutlet weak var eventStartDateInputView: UIDatePicker!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // image collection
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self

        pickerConfig.filter = .images
        pickerConfig.selectionLimit = 4
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addEventToCal))
        self.navigationItem.rightBarButtonItem = addButton
        eventStartDateInputView.addTarget(self, action: #selector(handleEvnetStartDateChanged), for: .valueChanged)
        if readOnly {
            disableButton(submitButton)
            disableButton(pickImagesButton)
            nameInputView.isUserInteractionEnabled = false
            descriptionInputView.isEditable = false
            eventStartDateInputView.isUserInteractionEnabled = false
        }
        
//        if let e = event {
//            self.eventStartDateInputView.date = getDateFromString(e.startTime)
//            self.nameInputView.text = e.name
//            self.descriptionInputView.text = e.description
//            for path in e.imagePaths {
//                ImageDAO().getImageFromPath(path) { image in
//                    self.images.append(image!)
//                    self.imageCollectionView.reloadData()
//                }
//            }
//        }
    }
  
    func setEvent(_ eventId: String) {
        EventDAO().getEventById(eventId) { dataSnapshot in
            let event = Event(dataSnapshot.value as! [String: Any])
            self.event = event
            self.eventStartDateInputView.date = getDateFromString(self.event!.startTime)
            self.nameInputView.text = event.name
            self.descriptionInputView.text = event.description
            for path in event.imagePaths {
                ImageDAO().getImageFromPath(path) { image in
                    self.images.append(image!)
                    self.imageCollectionView.reloadData()
                }
            }
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
        if let event = self.event {
            return Event(id: event.id,name: name, description: description, startTime: getFormattedDateString(eventStartDate), organiserEmail: "\(UUID().uuidString)@gmail.com", imagePaths: [])
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
    
    @objc func addEventToCal() {
        store.requestAccess(to: .event) { [weak self] success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store, let event = self?.event else {
                        return
                    }
                    let newEvent = EKEvent(eventStore: store)
                    newEvent.title = event.name
                    newEvent.startDate = getDateFromString(event.startTime ?? getFormattedDateString(Date()))
                    newEvent.notes = event.description
                    let structuredLocation = EKStructuredLocation(title: "Boston")
                    //42.33558656176007, -71.07878022456383
                    structuredLocation.geoLocation = CLLocation(latitude: 42.33558656176007, longitude: -71.07878022456383)
                    newEvent.structuredLocation = structuredLocation
                    let vc = EKEventEditViewController()
//                    let vc = EKEventViewController()
                    vc.event = newEvent
                    vc.editViewDelegate = self
                    self?.present(vc, animated: true)
//                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
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
