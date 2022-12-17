//
//  ProfileVC.swift
//  NEUEvents
//
//  Created by tanay on 12/13/22.
//

import UIKit

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signoutButtonClicked(_ sender: Any) {
        signout()
        performSegue(withIdentifier: "LoginSegue", sender: nil)
    }
}

class LoginSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dest = self.destination
        dest.modalPresentationStyle = .fullScreen
        dest.modalTransitionStyle = .flipHorizontal
        src.present(dest, animated: true)
    }
}
