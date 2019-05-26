//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 13/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var imageCache = [String: UIImage]()
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        
        lastUrlUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Error getting image", err)
                return
            }
            
            if url.absoluteString != self.lastUrlUsedToLoadImage {
                return
            }
            
            guard let imageData = data else {return}
            
            if let image = UIImage(data: imageData) {
                self.imageCache[url.absoluteString] = image
                DispatchQueue.main.async {
                    self.image = image
                }
            }
            }.resume()
        
    }
    
}
