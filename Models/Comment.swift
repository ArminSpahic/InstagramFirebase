//
//  Comments.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 22/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    
    let creationDate: String
    let text: String
    let userId: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.creationDate = dictionary["creationDate"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        self.userId = dictionary["userId"] as? String ?? ""
    }
    
}
