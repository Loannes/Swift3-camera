//
//  IngCaProtocol.swift
//  ingca-beta
//
//  Created by Loannes on 2017. 7. 7..
//  Copyright © 2017년 Loannes. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

enum CameraMode {
    case video, picture
}

protocol IngCaProtocol {
    var       timer: Timer? { get }
    var imagePicker: UIImagePickerController { get }
    
    var       isRecording: Bool  { get }
    var     recordingTime: Float { get }
    var takenPictureCount: Int   { get }
    
    func configureCamera(mode: CameraMode)
    func openPhotosApp()
}

protocol IngCaVMProtocol {
    func cameraOverlayView(mode: CameraMode) -> UIView
    
    // Video Button
    var videoRecordingButton: UIButton { get }
    
    // Picture Button
    var photoShutterButton: UIButton { get }
    
    var cameraRotateButton: UIButton { get }
    var stateLabel: UILabel { get }
    var closeButton: UIButton { get }
}

extension IngCaProtocol {
    func configureCamera(mode: CameraMode) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.showsCameraControls = false
        
        if mode == .video {
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.videoQuality = .typeHigh
        } else if mode == .picture {
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
        }
    }
    
    func openPhotosApp() {
        if UIApplication.shared.canOpenURL(URL(string:"photos-redirect://")!) {
            if let url = URL(string: "photos-redirect://") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

extension UIImagePickerController {
    func rotate() {
        if self.cameraDevice == .front {
            self.cameraDevice = .rear
        } else {
            self.cameraDevice = .front
        }
    }
}

extension UIView {
    func addSubViews(views: Array<UIView>) {
        for view in views {
            self.addSubview(view)
        }
    }
}
