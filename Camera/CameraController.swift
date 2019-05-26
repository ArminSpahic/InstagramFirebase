//
//  CameraController.swift
//  InstagramFirebase
//
//  Created by Armin Spahic on 19/01/2019.
//  Copyright © 2019 Armin Spahic. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, DismissPreviewImage, UIViewControllerTransitioningDelegate {
    
    func dismissPreviewImageView() {
        //self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
        return button
    }()
    
    let rightBackButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(UIImage(named: "right_arrow_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleCapture() {
        
        let settings = AVCapturePhotoSettings()
        guard let previewPhotoFormat = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoFormat]
        
        output.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        
        let previewImage = UIImage(data: imageData!)
        
        let previewPhotoContainerView = PreviewPhotoContainerView()
        previewPhotoContainerView.delegate = self
        view.addSubview(previewPhotoContainerView)
        previewPhotoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        previewPhotoContainerView.previewImageView.image = previewImage
        
//        let previewImageView = UIImageView(image: previewImage)
//        view.addSubview(previewImageView)
//        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    @objc fileprivate func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCaptureSession()
        
        view.backgroundColor = UIColor.green
        
        setupHUD()
       
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    //delegate methods for view transition
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        return customAnimationDismisser
    }
    
    fileprivate func setupHUD() {
        
        view.addSubview(rightBackButton)
        view.addSubview(captureButton)
        
        rightBackButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: 50)
        
        captureButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -24, paddingRight: 0, width: 80, height: 80)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaptureSession() {

        //setup inputs
        let captureSession = AVCaptureSession()

        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

        do {

            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

        } catch let err {

            print("Error loading camera", err)
            return

        }

        //setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        //setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
}
