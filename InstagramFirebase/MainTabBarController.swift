//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 08/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let photoNavController = UINavigationController(rootViewController: photoSelectorController)
            present(photoNavController, animated: true, completion: nil)
               
            return false
        }
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViewController()
        
    }
    private func setupViewController() {
        
        //home
        let homeNavController = templateNavController(unselectedImage: "home_unselected", selectedImage: "home_selected", rootViewController: HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //search
        let searchNavController = templateNavController(unselectedImage: "search_unselected", selectedImage: "search_selected", rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //plus
        let plusNavController = templateNavController(unselectedImage: "plus_unselected", selectedImage: "plus_unselected")
        
        //like
        let likeNavController = templateNavController(unselectedImage: "like_unselected", selectedImage: "like_selected")

        //user profile
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        let userProfileNavController = templateNavController(unselectedImage: "profile_unselected", selectedImage: "profile_selected", rootViewController: userProfileController)
        
        tabBar.tintColor = UIColor.black
        
        self.viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else {return}
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: String, selectedImage: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        let viewController = rootViewController 
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = UIImage(named: unselectedImage)
        navController.tabBarItem.selectedImage = UIImage(named: selectedImage)
        return navController
    }
}
