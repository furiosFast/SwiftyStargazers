//
//  User.swift
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

class User: NSObject, NSCoding {
    
    var username : String
    var avatarUrl : String

    
    init(_ username: String, _ avatarUrl: String) {
        self.username = username
        self.avatarUrl = avatarUrl
    }
        
    internal required init?(coder aDecoder: NSCoder) {
        self.username = aDecoder.decodeObject(forKey: "username") as! String
        self.avatarUrl = aDecoder.decodeObject(forKey: "avatarUrl") as! String
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(self.username, forKey: "username")
        encoder.encode(self.avatarUrl, forKey: "avatarUrl")
    }

}
