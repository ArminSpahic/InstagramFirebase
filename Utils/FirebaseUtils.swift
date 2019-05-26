//
//  FirebaseUtils.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 17/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else {return}
            print("UserDic", userDictionary)
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (err) in
            print("Error getting users", err)
        }
        
    }
}
