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
    
    
    func getStargazers(_ owner: String, _ repositoryName: String, _ page: Int){
        if page == 1 {
            self.stargazers.removeAll()
        }
        
        if owner.isEmpty {
            self.delegate?.stargazersDataNotAvailable?(error: "owner is empty")
            return
        }
        if repositoryName.isEmpty {
            self.delegate?.stargazersDataNotAvailable?(error: "repositoryName is empty")
            return
        }
        
        let urlString = "https://api.github.com/repos/\(replaceHtmlCharset(owner))/\(replaceHtmlCharset(repositoryName))/stargazers?page=\(page)"
        guard let url = URL(string: urlString) else {
            self.delegate?.stargazersDataNotAvailable?(error: "Invalid input")
            return
        }
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
            for i in 0..<json.count {
                //0 - username
                let username = json[i]["login"].stringValue

                //1 - avatar link
                let avatarUrl = json[i]["avatar_url"].stringValue
                
                
                if !username.isEmpty && !avatarUrl.isEmpty {
                    self.stargazers.append(User(username, UIImage(systemName: "person.crop.circle.fill")!, avatarUrl))
                }
            }
            
            
            if self.stargazers.isEmpty {
                self.delegate?.stargazersDataNotAvailable?(error: "No result found.")
            } else {
                self.delegate?.stargazersDataReady(stargazers: self.stargazers)
            }
        }
    }
    
}
