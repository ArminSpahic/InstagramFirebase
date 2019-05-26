//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 09/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let headerId = "headerId"
    let cellId = "cellId"
    
    let activityIndicator: UIActivityIndicatorView = {
       let ai = UIActivityIndicatorView()
        ai.style = .gray
        ai.isHidden = false
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.white
        setupPhotoNavBar()
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        fetchPhotos()
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    var images = [UIImage]()
    var selectedImage: UIImage?
    var assets = [PHAsset]()
    var header: PhotoSelectorHeader?
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    guard let image = image else {return}
                    self.images.append(image)
                    self.assets.append(asset)
                    
                    if count == allPhotos.count - 1 {
                        guard let firstImage = self.images.first else {return}
                        self.selectedImage = firstImage
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                        }
                        
                    }
                })
            }
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupPhotoNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.black
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelBtn))
        let nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNextBtn))
        navigationItem.leftBarButtonItem = cancelBtn
        navigationItem.rightBarButtonItem = nextBtn
    }
    
    @objc fileprivate func handleCancelBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleNextBtn() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.imageChosen = header?.photoHeaderImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                let targetSize = CGSize(width: 1200, height: 1200)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    header.photoHeaderImageView.image = image
                }
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.cellImage = images[indexPath.item]
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageLocal = images[indexPath.item]
        self.selectedImage = selectedImageLocal
        collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: (view.frame.width - 2) / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
}
