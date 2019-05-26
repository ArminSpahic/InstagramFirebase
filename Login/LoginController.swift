//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 09/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    let instaImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Instagram_logo_white")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return textField
    }()
    
    let passwordTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5.0
        button.tintColor = UIColor.white
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                print("Error loging in:", err)
                return
            }
            
            print("Successfully logged back in with user", user?.user.uid ?? "")
            guard let user = user else {return}
            
            let tabBarController = MainTabBarController()
            self.present(tabBarController, animated: true, completion: nil)
        }
    }
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: " Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue()]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.tintColor = UIColor.black
        button.addTarget(self, action: #selector(handleDontHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleTextInputChange() {
        let isFormValid = emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        
        if isFormValid {
            loginButton.backgroundColor = UIColor.mainBlue()
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            loginButton.isEnabled = false
        }
    }
    
    @objc fileprivate func handleDontHaveAccount() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        logoContainerView.addSubview(instaImageView)
        instaImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor).isActive = true
        instaImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor).isActive = true
        
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor.white
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
        
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: 0, height: 140)
    }
}
