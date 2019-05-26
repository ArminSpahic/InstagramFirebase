//
//  PhotoCell.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 10/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    var cellImage: UIImage? {
        didSet {
            if let image = cellImage {
                photoImageView.image = image
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
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.yellow
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    func setupViews() {
        
        addSubview(photoImageView)
        photoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
    }
}
