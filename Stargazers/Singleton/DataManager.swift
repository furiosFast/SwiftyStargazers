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
            self.delegate?.stargazersDataNotAvailable?(error: loc("validationError_EMPTYOWNER"))
            return
        }
        if repositoryName.isEmpty {
            self.delegate?.stargazersDataNotAvailable?(error: loc("validationError_EMPTYREPONAME"))
            return
        }
        
        guard let url = URL(string: "https://api.github.com/repos/\(replaceHtmlCharset(owner))/\(replaceHtmlCharset(repositoryName))/stargazers?page=\(page)") else {
            self.delegate?.stargazersDataNotAvailable?(error: String(format: loc("GENERICERROR"), loc("dataManager_ERRORNINVALIDURL")))
            return
        }
        AFManager.request(url, method: .get).responseJSON { response in
            if let er = response.error {
                self.delegate?.stargazersDataNotAvailable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.stargazersDataNotAvailable?(error: String(format: loc("GENERICERROR"), loc("dataManager_ERRORNILJSON")))
                return
            }
            
            let json = JSON(ilJson)
            for i in 0..<json.count {
                //0 - username
                let username = json[i]["login"].stringValue

                //1 - avatar link
                let avatarUrl = json[i]["avatar_url"].stringValue
                
                
                if !username.isEmpty && !avatarUrl.isEmpty {
                    self.stargazers.append(User(username, avatarPlaceholder, avatarUrl))
                }
            }
            
            
            if self.stargazers.isEmpty {
                self.delegate?.stargazersDataNotAvailable?(error: loc("dataManager_NORESULT"))
            } else {
                self.delegate?.stargazersDataReady(stargazers: self.stargazers)
            }
        }
    }
    
    
    //MARK:- Private functions
    
    /// Parse string for HTML url call
    /// - Parameter text: text to parse
    /// - Returns: parsed text
    private func replaceHtmlCharset(_ text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? text
    }
    
}
