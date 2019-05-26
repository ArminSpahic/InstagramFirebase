//
//  UserSearchCell.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 17/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            guard let username = user?.username else {return}
            usernameLabel.text = username
            
            guard let userProfileImage = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: userProfileImage)
        }
    }
    
    let separatorView: UIView = {
       let separator = UIView()
        separator.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return separator
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        usernameLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: 0, height: 30)
        
        separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 58, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
}
