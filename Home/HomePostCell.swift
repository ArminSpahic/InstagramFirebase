//
//  HomeCell.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 16/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?

    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else {return}
            homeImageView.loadImage(urlString: imageUrl)
            
            heartButton.setImage(post?.hasLiked == true ? UIImage(named: "like_selected")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            usernameLabel.text = post?.user.username
            
            guard let userProfileUrl = post?.user.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: userProfileUrl)
            
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        
        guard let post = self.post else {return}
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 6)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        self.captionLabel.attributedText = attributedText
        
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let homeImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var heartButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var bubbleButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let planeButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc fileprivate func handleComment() {
        
        guard let post = self.post else {return}
        delegate?.didTapComment(post: post)
        
    }
    
    @objc fileprivate func handleLike() {
        
        delegate?.didTapLike(for: self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = UIColor.white
        addSubview(homeImageView)
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(captionLabel)
        
        userProfileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
         usernameLabel.anchor(top: self.topAnchor, left: userProfileImageView.rightAnchor, bottom: homeImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        optionsButton.anchor(top: self.topAnchor, left: nil, bottom: homeImageView.topAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        homeImageView.anchor(top: userProfileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setupStackButtons()
        
        captionLabel.anchor(top: heartButton.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: 0, height: 0)
    }
    
    fileprivate func setupStackButtons() {
        let stackView = UIStackView(arrangedSubviews: [heartButton, bubbleButton, planeButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        stackView.anchor(top: homeImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: stackView.topAnchor, left: nil, bottom: stackView.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 50, height: 50)
    }
    
}
