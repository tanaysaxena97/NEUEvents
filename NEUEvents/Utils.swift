//
//  Utils.swift
//  assignment5
//
//  Created by tanay on 10/19/22.
//

import UIKit
import SystemConfiguration
import GoogleSignIn

//let imageCache: NSCache = NSCache<String, UIImage>()

extension Optional where Wrapped == String {
    func toIntOpt() -> Int? {
        return Int(self!)
    }
    
    func toDoubleOpt() -> Double? {
        return Double(self!)
    }
}

func getFormattedDateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

func getDateFromString(_ stringDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.date(from: stringDate)!
}

func showErrorAlert(_ context: UIViewController, _ error: String) {
    let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    context.present(alert, animated: true, completion: nil)
//    UIApplication.shared.windows.first?
}

func showConfirmationAlert(_ context: UIViewController, _ message: String, cancelAction: @escaping ((UIAlertAction) -> Void), okAction: @escaping ((UIAlertAction) -> Void)) {
    let alert = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: cancelAction))
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: okAction))
    context.present(alert, animated: true, completion: nil)
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

func getDataFromImage(_ image: UIImage) -> Data {
    image.pngData()!
}

func getImageFromData(_ data: Data) -> UIImage {
    UIImage(data: data)!
}

func getImageFromDataForList(_ data: Data, size: CGSize = CGSize(width: 50, height: 50)) -> UIImage {
    let image = UIImage(data: data)!
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: .zero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func getImageFromDataForList(_ image: UIImage, size: CGSize = CGSize(width: 50, height: 50)) -> UIImage {
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: .zero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func resizeImage(_ image: UIImage, size: CGSize = CGSize(width: 50, height: 50)) -> UIImage {
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: .zero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func connectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }

    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return (isReachable && !needsConnection)
}

//func getJsonViaRest(_ path: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
//    if !connectedToNetwork() {
//        showErrorAlert("network not available")
//        return
//    }
//    let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
//    sessionConfig.allowsCellularAccess = true
//    sessionConfig.httpAdditionalHeaders = ["Accept": "application/json"]
//    let session = URLSession(configuration: sessionConfig)
//    let url = URL(string: Constants.REST_URL.rawValue + path)!
//    session.dataTask(with: url, completionHandler: completionHandler).resume()
//}

let imageDct = ["xbox": UIImage(named: "xbox")!,
                "ps5": UIImage(named: "ps5")!,
                "monitor": UIImage(named: "monitor")!,
                "mouse": UIImage(named: "mouse")!,
                "keyboard": UIImage(named: "keyboard")!]

func validateFormText(_ text: String?) -> Bool {
    if let txt = text {
        return !txt.isEmpty && !(txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    return false
}

func signout() {
    GIDSignIn.sharedInstance.signOut()
}
