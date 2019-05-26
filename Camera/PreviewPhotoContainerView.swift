//
//  PreviewPhotoContainerView.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 21/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Photos

protocol DismissPreviewImage: class {
    func dismissPreviewImageView()
}

class PreviewPhotoContainerView: UIView {
    
    var delegate: DismissPreviewImage?
    
    let cancelButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cancel_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "save_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    let previewImageView: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    @objc fileprivate func handleCancel() {
        //delegate?.dismissPreviewImageView()
        self.removeFromSuperview()
    }
    
    @objc fileprivate func handleSave() {
        
        print("Saved")
        guard let previewImage = previewImageView.image else {return}
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library", err)
                return
            }
            
            print("Successfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved successfully"
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.layer.cornerRadius = 5.0
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                
                self.addSubview(savedLabel)
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (completed) in
                        
                        savedLabel.removeFromSuperview()
                        
                    })
                    
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = UIColor.green
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        
        previewImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        cancelButton.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        saveButton.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: -12, paddingRight: 0, width: 50, height: 50)
    }
    
}
