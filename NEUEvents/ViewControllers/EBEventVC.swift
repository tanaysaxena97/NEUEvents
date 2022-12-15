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
    @IBOutlet weak var eventNameView: UITextField!
    @IBOutlet weak var eventStartDateView: UITextField!
    @IBOutlet weak var eventSummaryView: UITextView!
    var event: EBEvent?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let e = event {
            eventImageView.kf.setImage(with: URL(string: e.imageURL))
            eventNameView.text = e.name
            eventSummaryView.text = e.summary
            eventStartDateView.text = e.startDate
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
