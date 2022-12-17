//
//  AboutVC.swift
//  NEUEvents
//
//  Created by tanay on 12/17/22.
//

import UIKit

class AboutVC: UIViewController {
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        let about = """
Introduction
    This application aims to provide the latest events and programs on
    and around the NEU campus. The events would range from tech
    webinars/seminars to career fairs, hackathons,
    parties, and outdoor programs.
Key features
    Event sources and organizers -
        - Organizers/student groups would be able to post the details
            of their events
        - Eventbrite Rest API will be utilized for gathering event
            details happening around Boston
        - Event details/images would be stored in the firebase.
    End users -
        - Users will be able to view upcoming and latest events and
            register for them.
        - Users can add reminder to their apple calendar
        - Events can be viewed based on user preferences

By-
Tanay Saxena
saxena.t@northeastern.edu
"""
        textView.text = about
    }
}
