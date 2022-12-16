//
//  EBEventVC.swift
//  NEUEvents
//
//  Created by tanay on 12/14/22.
//

import UIKit
import Kingfisher

class EBEventVC: UIViewController {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventStartDateView: UITextField!
    @IBOutlet weak var eventSummaryView: UITextView!
    @IBOutlet weak var eventNameView: UITextView!
    @IBOutlet weak var eventAddressView: UITextField!
    var event: EBEvent?
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}
