//
//  CommentInputTextView.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 25/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    let placeHolderLabel: UILabel = {
       let label = UILabel()
        label.text = "Enter Comment"
        label.textColor = UIColor.lightGray
        return label
    }()
    
    func showPlaceholderLabel() {
        placeHolderLabel.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(placeHolderLabel)
        placeHolderLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func handleTextChange() {
        placeHolderLabel.isHidden = !self.text.isEmpty
    }
    
}
