//
//  CommentsViewController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 21/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {
  
    var commentTextField: UITextField?
    
    let cellId = "cellId"
    
    var selectedPost: Post? {
        didSet {
            guard let post = selectedPost else {return}
            print("Selected post is:", post.caption)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        setupTapGesture()
        
        navigationItem.title = "Comments"
        
        collectionView.register(CommentViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.isScrollEnabled = true
        
        fetchComments()
    }
    
    fileprivate func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(
            dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    var comments = [Comment]()
    
    fileprivate func fetchComments() {
        guard let postId = selectedPost?.id else {return}
        
        let ref = Database.database().reference().child("comments").child(postId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            guard let snaps = snapshot.value as? [String: Any] else {return}
            print(snaps)
            
            guard let uid = snaps["userId"] as? String else {return}
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                
                let comment = Comment(user: user, dictionary: snaps)
                self.comments.append(comment)
                self.collectionView.reloadData()
                
            })
        }) { (err) in
            print("Error fetching comments", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CommentViewCell
        cell.comment = comments[indexPath.item]
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //dynamic cell sizing
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentViewCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true )
        tabBarController?.tabBar.isHidden = false
    }
    
   lazy var containerView: CommentInputAccessoryView = {
    
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView

    }()
    
    func updateComments(commentText: String) {
        
        let text = commentText
        
        guard let postId = selectedPost?.id else {return}
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let values = ["text": text, "userId": userId, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Error saving comment", err)
                return
            }
            
            print("Successfully saved comment")
            
            let commentTextField = self.containerView.subviews[1] as! UITextView
            commentTextField.resignFirstResponder()
            self.containerView.clearCommentTextField()
            
        }
    }
    
    @objc fileprivate func dismissKeyboard() {
        containerView.subviews[1].resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
 
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
