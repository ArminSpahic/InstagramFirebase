//
//  PhotoHeader.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 10/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    
    var selectedImage: UIImage? {
        didSet {
            guard let image = selectedImage else {return}
            photoHeaderImageView.image = image
        }
    }
    
    let photoHeaderImageView: UIImageView = {
       let iv = UIImageView()
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
        addSubview(photoHeaderImageView)
        photoHeaderImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
