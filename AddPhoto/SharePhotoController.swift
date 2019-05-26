//
//  SharedPhotoController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 11/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var imageChosen: UIImage? {
        didSet {
            guard let image = imageChosen else {return}
            photoImageView.image = image
        } 
    }
    
    let activityIndicator: UIActivityIndicatorView = {
       let ai = UIActivityIndicatorView()
        ai.style = .whiteLarge
        ai.isHidden = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let photoImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let shareTxtField: UITextView = {
       let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
     let dimmedView = UIView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        setupShareBarButtonItem()
        setupImageAndTextViews()
        setupActivityIndicator()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func handleTap() {
        shareTxtField.resignFirstResponder()
    }
    
    fileprivate func setupImageAndTextViews() {
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(photoImageView)
        photoImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: 0, width: 84, height: 0)

        containerView.addSubview(shareTxtField)
        shareTxtField.anchor(top: photoImageView.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 84)
    }
    
    fileprivate func setupShareBarButtonItem() {
        let shareBarButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        navigationItem.rightBarButtonItem = shareBarButton
    }
    
    fileprivate func waitForShare() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if let window = UIApplication.shared.keyWindow {
            dimmedView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.dimmedView.frame = window.frame
            window.addSubview(dimmedView)
        }
        
    }
    
    @objc fileprivate func handleShare() {
        shareTxtField.resignFirstResponder()
        guard let captionText = shareTxtField.text, captionText.characters.count > 0 else {return}
        guard let image = imageChosen else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}
        
        waitForShare()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.dimmedView.removeFromSuperview()
               self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error uploading image", err)
                return
            }
            print("Successfully uplodaded image")
            storageRef.downloadURL(completion: { (downloadUrl, err) in
                if let err = err {
                    self.dimmedView.removeFromSuperview()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Error downloading image url", err)
                    return
                }
                
                guard let profileImageUrl = downloadUrl?.absoluteString else {return}
                print("Successfully downloaded image url", profileImageUrl)
                self.saveToDatabaseWithImageUrl(imageUrl: profileImageUrl)
            })
        }
        
        
    }
    
    static let updateFeedNotificationName =  NSNotification.Name(rawValue: "RefreshHomeFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let captionText = shareTxtField.text else {return}
        guard let postImage = imageChosen else {return}
        
       let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl, "captionText": captionText, "imageHeight": postImage.size.height, "imageWidth": postImage.size.width, "creationDate": Date.timeIntervalSinceReferenceDate] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.dimmedView.removeFromSuperview()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save posts into db")
                return
            }
            
            print("Successfully saved posts to db")
            self.activityIndicator.stopAnimating()
            self.dimmedView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
}
