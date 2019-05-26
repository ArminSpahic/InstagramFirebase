//
//  CommentViewCell.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 22/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class CommentViewCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else {return}
        
            userProfileImageView.loadImage(urlString: comment.user.profileImageUrl)
            
                let attributedText = NSMutableAttributedString(string: "\(comment.user.username) ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "\(comment.text)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
                self.textView.attributedText = attributedText
            }
        }
    
    let separatorStyleLine: UIView = {
       let line = UIView()
        line.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return line
    }()
    
    let textView : UITextView = {
       let textVIew = UITextView()
        textVIew.font = UIFont.systemFont(ofSize: 14)
        textVIew.isScrollEnabled = false
        return textVIew
    }()
    
    let userProfileImageView: CustomImageView = {
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
        addSubview(userProfileImageView)
        addSubview(textView)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        textView.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: -4, paddingRight: -4, width: 0, height: 0)
    
    }
    
}
