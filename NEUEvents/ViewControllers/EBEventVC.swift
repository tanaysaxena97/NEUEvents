//
//  EBEventVC.swift
//  NEUEvents
//
//  Created by tanay on 12/14/22.
//

import UIKit
import Kingfisher
import EventKitUI
import EventKit

class EBEventVC: UIViewController, EKEventEditViewDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventStartDateView: UITextField!
    @IBOutlet weak var eventSummaryView: UITextView!
    @IBOutlet weak var eventNameView: UITextView!
    @IBOutlet weak var eventAddressView: UITextField!
    var event: EBEvent?
    let store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addEventToCal))
        self.navigationItem.rightBarButtonItem = addButton
        if let e = event {
            eventImageView.kf.setImage(with: URL(string: e.imageURL))
            eventNameView.text = e.name
            eventSummaryView.text = e.summary
            eventStartDateView.text = "Event Date: " + e.startDate
            eventAddressView.text = "Venue: " + e.address
        }
    }
    
    func setEvent(_ event: EBEvent) {
        self.event = event
    }
    
    @IBAction func onBuyTicketsTapped(_ sender: UIButton) {
        if let e = event, let url = URL(string: e.ticketURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
    }
    
    @objc func addEventToCal() {
        store.requestAccess(to: .event) { [weak self] success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store, let event = self?.event else {
                        return
                    }
                    let format = "yyyy-MM-dd"
                    let newEvent = EKEvent(eventStore: store)
                    newEvent.title = event.name
                    newEvent.startDate = getDateFromString(event.startDate ?? getFormattedDateString(Date(), format: format), format: format)
                    newEvent.notes = event.summary
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
