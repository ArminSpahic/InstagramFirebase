//
//  User.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 16/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
    
}
