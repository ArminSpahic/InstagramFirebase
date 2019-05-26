//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 08/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    var isGridView = true
    
    var userId: String?
    
    let headerId = "headerId"
    let cellId = "cellId"
    let homeCellId = "homeCellId"
    var user: User?
    
    @objc private func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                print("User signed out")
            } catch let signOutErr {
                print("Failed to sign out", signOutErr)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homeCellId)
        
        collectionView?.backgroundColor = UIColor.white
    
        fetchUser()
        
        setupLogOutButton()
        
        //fetchPosts()
        //fetchOrederedPosts()
        
        
    }
    var isFinishedPaging = false
    var posts = [Post]()
    
    fileprivate func paginatePosts() {
        
        guard let uid = self.user?.uid else {return}
        
        let ref = Database.database().reference().child("posts").child(uid)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else {return}
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                
                post.id = snapshot.key
                
                self.posts.append(post)
            })
            
            self.posts.forEach({ (post) in
                print(post.id ?? "")
            })
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to paginate posts", err)
        }
        
    }
    
    fileprivate func fetchOrederedPosts() {
        guard let uid = self.user?.uid else {return}
  
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            print("Dic", dictionary)
            
            guard let user = self.user else {return}
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
            self.collectionView?.reloadData()
        }) { (err) in
                print("Error fetching ordered posts", err)
        }
    }
    
//    fileprivate func fetchPosts() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        
//        let ref = Database.database().reference().child("posts").child(uid)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let snaps = snapshot.value as? [String: Any] else {return}
//            print("Snapshot of data is:", snaps)
//            
//            snaps.forEach({ (key, value) in
//                guard let dictionary = value as? [String: Any] else {return}
//                
//                guard let imageUrl = dictionary["imageUrl"] as? String else {return}
//                print("imageUrl:\(imageUrl)")
//                
//                guard let user = self.user else {return}
//                let post = Post(user: user, dictionary: dictionary)
//                
//                self.posts.append(post)
//                
//            })
//             print("Posts: \(self.posts)")
//            self.collectionView?.reloadData()
//            
//        }) { (err) in
//            print("Error getting snapshot of data:", err)
//        }
//    }
    
    fileprivate func setupLogOutButton() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        header.userInfo = user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //fire off the paginate cell
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        
        if (isGridView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (isGridView) {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 // username userprofileimageview
            height += view.frame.width + height
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }     
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    fileprivate func fetchUser() {
        
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView.reloadData()
            
            self.paginatePosts()
        }

    }
}


