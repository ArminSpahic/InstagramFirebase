//
//  HomeFeedController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 16/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    var selectedItem: Post?
    
    //delegate methods
    func didTapComment(post: Post) {
        
        let commentsViewController = CommentsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsViewController.selectedPost = post
        navigationController?.pushViewController(commentsViewController, animated: true)
        
    }
    
    func didTapLike(for cell: HomePostCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        
        guard let postId = post.id else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to like post", err)
                return
            }
            
            print("Successfully liked post")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            
            self.collectionView.reloadItems(at: [indexPath])
        }
        
    }

    let homeCellId = "homeCellId"
    var posts = [Post]()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homeCellId)
        
        setupNavigationItems()
        fetchUser()
        fetchAllPosts()
        setupRefreshControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: SharePhotoController.updateFeedNotificationName, object: nil)
    }
    
    fileprivate func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc fileprivate func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchOrderedPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Error getting user ids:", err)
        }
        
    }

    fileprivate func fetchUser() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
        
        Database.fetchUserWithUID(uid: currentUserUID) { (user) in
            self.user = user
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user )
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        //guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snaps = snapshot.value as? [String: Any] else {return}
            print("Another postDic", snaps)
            
            self.collectionView.refreshControl?.endRefreshing()
            
            snaps.forEach({ (key, value) in
                guard let postDictionary = value as? [String: Any] else {return}
                
                var post = Post(user: user, dictionary: postDictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView.reloadData()
                    
                }, withCancel: { (err) in
                    print("Error fetching likes", err)
                })
            })
            
        }) { (err) in
            print("Error fetching posts in home feed", err)
        }
    }
    
    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCameraBtn))
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
    }
    
    @objc fileprivate func handleCameraBtn() {
        let cameraController = CameraController()
        self.present(cameraController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCellId, for: indexPath) as! HomePostCell
       cell.delegate = self
        cell.post = posts[indexPath.item]
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // username userprofileimageview
        height += view.frame.width + height
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
}
