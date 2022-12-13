//
//  ViewController.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import UIKit
import FirebaseCore
import GoogleSignIn

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GIDSignIn.sharedInstance.currentUser != nil {
            goToHomeScreen()
        }
    }
    
    func completionHandler(_ token: String?, _ error: Error?) {
        if token != nil {
            goToHomeScreen()
            print("sign in done")
        }
    }

    @IBAction func onSignInTapped(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance.signIn(
            with: GIDConfiguration(clientID: "344999646530-71q4at4g6fs9psia3f02h8up2e3k1j08.apps.googleusercontent.com"),
            presenting: self, callback: { user, error in
                print(user?.description)
                if let token = user?.authentication.idToken {
                    self.completionHandler(token, nil)
                    return
                }
                guard let error = error as? GIDSignInError else {
                    fatalError("No token and no GIDSignInError: \(String(describing: error))")
                }
                self.completionHandler(nil, error)
            }
        )
    }

    func goToHomeScreen() {
        self.performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
}

class HomeSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dest = self.destination
        let destFvc = dest as! UITabBarController
        let srcLvc = (src as! LoginVC)
        src.present(dest, animated: true)
    }
}
