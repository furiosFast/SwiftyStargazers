//
//  Config.swift
//  Stargazers
//
//  Created by Marco Ricca on 02/12/2020
//
//  Created for Stargazers in 02/12/2020
//  Using Swift 5.0
//  Running on macOS 10.15
//
//
//


import UIKit
import Alamofire


//MARK: - Shared variables

public var AFManager = Session()
public let avatarPlaceholder = UIImage(systemName: "person.crop.circle.fill")!
public let ID_STORYBOARD_SEARCH = "id_storyboard_search"


//MARK: - Shared functions

/// Exceute actions after specified time (in seconds)
/// - Parameters:
///   - delay: seconds
///   - closure: actions to do
func delay(_ delay:Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

/// Short function for localize string
/// - Parameter localizedKey: string key to localize
func loc(_ localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}

///Save the app user preferences
/// - Parameters:
///   - any: value
///   - key: key
func savePreferenceLocal(_ any: Any, _ key: String) {
    UserDefaults.standard.set(any, forKey: key)
    UserDefaults.standard.synchronize()
}

/// Function that set the Alamofire configuration
/// - Parameter timeOut: time interval that indicate the time out for every call to the web service made with alamofire
func setAlamofire(_ timeOut: TimeInterval = 15.0){
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeOut
    configuration.timeoutIntervalForResource = timeOut
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    AFManager = Alamofire.Session(configuration: configuration)
}


//MARK: - Shared extension

#if os(iOS)
extension UIViewController {
    
    func simpleAlert(title: String = "", text: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let simpleAlert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        simpleAlert.addAction(UIAlertAction(title: loc("alert_OKBUTTON"), style: .cancel, handler: handler))
        self.present(simpleAlert, animated: true, completion: nil)
    }
    
}

extension UINavigationItem {
    
    func setTitle(_ title: String, subtitle: String) {
        let appearance = UINavigationBar.appearance()
        let textColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .label

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
        titleLabel.textColor = textColor
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.caption2)
        subtitleLabel.textColor = textColor.withAlphaComponent(0.75)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        
        self.titleView = stackView
    }
    
}
#endif
