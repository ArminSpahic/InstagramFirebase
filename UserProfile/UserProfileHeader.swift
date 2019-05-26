//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 08/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate: class {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionViewCell {
    
    weak var delegate: UserProfileHeaderDelegate?
    
    var userInfo: User? {
        didSet {
            guard let username = userInfo?.username else {return}
            usernameLabel.text = username
            
            guard let urlString = userInfo?.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: urlString)
            
            setupEditFollowButton()
        }
    }
    
    fileprivate func setupUnfollowBtn() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.white
        self.editProfileFollowButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    fileprivate func setupFollowBtn() {
        editProfileFollowButton.setTitle("Follow", for: .normal)
        editProfileFollowButton.backgroundColor = UIColor.mainBlue()
        editProfileFollowButton.setTitleColor(UIColor.white, for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    fileprivate func setupEditFollowButton() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = userInfo?.uid else {return}
        
        if currentLoggedInUserId == userId {
            //handle edit profile button
            editProfileFollowButton.isEnabled = false
            return
        } else {
            //check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnfollowBtn()
                } else {
                    self.setupFollowBtn()
                }
            }) { (err) in
                    print("Failed to check if following", err)
            }
            
        }
    }
    
    @objc fileprivate func handleEditProfileOrFollow() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        
        
        let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
        
        guard let userIdForFollowing = userInfo?.uid else {return}
        //unfollow
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            
            ref.child(userIdForFollowing).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                
                print("Successfully unfollowed user:", self.userInfo?.username ?? "")
                self.setupFollowBtn()
            }
        } else {
            //follow
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            
            let values = [userIdForFollowing: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                
                print("Successfully followed user: ", self.userInfo?.username ?? "")
                self.setupUnfollowBtn()
            }
        }
        
       
    }
    
    let userProfileImageView: CustomImageView = {
       let imageView = CustomImageView()
        return imageView
    }()
    
    lazy var gridButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.addTarget(self, action: #selector(gridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        button.addTarget(self, action: #selector(listView), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon") , for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
        
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "follower", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5.0
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc fileprivate func gridView() {
        print("Grid")
        gridButton.tintColor = UIColor.mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    @objc fileprivate func listView() {
        print("List")
        listButton.tintColor = UIColor.mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(userProfileImageView)
        userProfileImageView.layer.cornerRadius = 80 / 2
        userProfileImageView.layer.masksToBounds = true
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 30, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: -4 , width: 0, height: 34)
        
        //setupProfileImage()
    }
    
    fileprivate func setupUserStats() {
        
        let userStatsStackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        userStatsStackView.distribution = .fillEqually
        userStatsStackView.axis = .horizontal
        userStatsStackView.spacing = 10
        
        addSubview(userStatsStackView)
        userStatsStackView.anchor(top: self.topAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 14, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: 0, height: 30)
        
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: nil, left: self.leftAnchor, bottom: stackView.topAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.3)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.3)

    }
    
    
//    fileprivate func setupProfileImage() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//
//            guard let dictionary = snapshot.value as? [String: Any] else {return}
//            guard let profileImageUrl = dictionary["profileImageUrl"] as? String else {return}
//            guard let url = URL(string: profileImageUrl) else {return}
//
//            URLSession.shared.dataTask(with: url) { (data, response, err) in
//                if let err = err {
//                    print("Failed to fetch profile image:", err)
//                    return
//                }
//                print(data)
//
//                guard let data = data else {return}
//                let image = UIImage(data: data)
//
//                DispatchQueue.main.async {
//                     self.userProfileImageView.image = image
//                }
//
//                }.resume()
//        }) { (err) in
//            print("Error fetching user:", err)
//        }
//
//    }
}
