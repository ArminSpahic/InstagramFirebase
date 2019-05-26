//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 25/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: class {
    func updateComments(commentText: String)
}

class CommentInputAccessoryView: UIView {
    
    weak var delegate: CommentInputAccessoryViewDelegate?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    fileprivate let sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.titleLabel?.numberOfLines = 0
        return sendButton
    }()
    
    fileprivate let commentTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    fileprivate let lineSeparatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return separatorView
    }()
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        self.addSubview(sendButton)
        sendButton.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: 50)
        
        self.addSubview(commentTextView)
        commentTextView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: 0, width: 0, height: 0)
        
        self.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSend() {
        guard let commentText = commentTextView.text else {return}
        delegate?.updateComments(commentText: commentText)
    }
    
}
