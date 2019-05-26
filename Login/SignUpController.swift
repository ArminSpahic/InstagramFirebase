//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 07/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plus_photo")? .withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc private func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    let emailTextField: UITextField = {
       let tf = UITextField()
        //tf.translatesAutoresizingMas kIntoConstraints = false
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)//Observing for changes in the textfield
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.isEmpty == false && usernameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        
        if isFormValid {
            signUpButton.backgroundColor = UIColor.mainBlue()
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            signUpButton.isEnabled = false
        }
    }
    
    let usernameTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Username"
        //tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Password"
        //tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let signUpButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
       let button = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Already have an account?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: " Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue()]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleSignUp() {
       
        guard let email = emailTextField.text, email.characters.count > 0 else {return}
        guard let username = usernameTextField.text, username.characters.count > 0 else {return}
        guard let password = passwordTextField.text, password.characters.count > 0 else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Failed to create user", err)
                return
        }
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile image", err)
                }
                
                storageRef.downloadURL(completion: { (downloadURL, err) in
                    
                    guard let profileImageUrl = downloadURL?.absoluteString else { return }
                    
                    print("Successfully uploaded profile image:", profileImageUrl)
                    
                    guard let uid = user?.user.uid else {return}
                    
                    let userValues = ["username": username, "email": email, "password": password, "profileImageUrl": profileImageUrl]
                    let values = [uid: userValues]
                    
                    let ref = Database.database().reference()
                    
                    ref.child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            print("Failed to save user info into db", err)
                            return
                        }
                        print("Successfully saved user into db")
                        let tabBarController = MainTabBarController()
                        self.present(tabBarController, animated: true, completion: nil)

                    })

                
            })
            
        })
    }
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //Plus Photo Button Constraints
//        view.addSubview(plusPhotoButton)
//        NSLayoutConstraint.activate([plusPhotoButton.heightAnchor.constraint(equalToConstant: 140),
//            plusPhotoButton.widthAnchor.constraint(equalToConstant: 140),
//            plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            plusPhotoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)])
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
    }

    fileprivate func setupInputFields() {

        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: 0, height: 200)
    }
    
}


