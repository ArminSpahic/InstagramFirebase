//
//  Post.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 13/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import Foundation

struct Post {
    
    var id: String?
    let user: User
    let imageUrl: String
    let caption: String
    let creationDate: Date
    
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["captionText"] as? String ?? ""
        self.user = user
        
        let timeInterval = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: timeInterval)
    }
}
