//
//  DataManager.swift
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
import SwiftyJSON

@objc protocol DataManagerDelegate: NSObjectProtocol {
    func stargazersDataReady(stargazers: [User])
    @objc optional func stargazersDataNotAvailable(error: String)
}

class DataManager: NSObject {
    
    var delegate : DataManagerDelegate?
    var stargazers: [User] = []
    
    
    func getStargazers(_ owner: String, _ repositoryName: String){
        if owner.isEmpty {
            self.delegate?.stargazersDataNotAvailable?(error: "owner is empty")
            return
        }
        if repositoryName.isEmpty {
            self.delegate?.stargazersDataNotAvailable?(error: "repositoryName is empty")
            return
        }
        
        let urlString = "https://api.github.com/repos/\(owner)/\(repositoryName)/stargazers"
        guard let url = URL(string: urlString) else { return }
        AFManager.request(url, method: .get).responseJSON { response in
            if let er = response.error {
                self.delegate?.stargazersDataNotAvailable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.stargazersDataNotAvailable?(error: "JSON is nil")
                return
            }
            
            let json = JSON(ilJson)
            if !json.isEmpty {
                self.stargazers.removeAll()
            }
            for i in 0..<json.count {
                //0 - username
                let username = json[i]["login"].stringValue

                //1 - avatar link
                let avatarUrl = json[i]["avatar_url"].stringValue
                
                
                self.stargazers.append(User(username, UIImage(systemName: "person.crop.circle.fill")!, avatarUrl))
            }
            
            
            DispatchQueue.main.async {
                self.delegate?.stargazersDataReady(stargazers: self.stargazers)
            }
        }
    }
    
}
