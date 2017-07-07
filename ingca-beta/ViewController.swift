//
//  ViewController.swift
//  ingca-beta
//
//  Created by Loannes on 2017. 7. 6..
//  Copyright © 2017년 Loannes. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, IngCaProtocol {
    var       timer: Timer?
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var       isRecording: Bool  = false
    var     recordingTime: Float = 0.0
    var takenPictureCount: Int   = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:
    // MARK: Method
    @IBAction func takeVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            configureCamera(mode: .video)
            
            self.present(imagePicker, animated: true, completion: {
                self.imagePicker.cameraOverlayView = self.cameraOverlayView(mode: .video)
                // self.imagePicker.takePicture()
            })
            isRecording = true
        }
    }
    
    @IBAction func takePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            configureCamera(mode: .picture)
            
            self.present(imagePicker, animated: true, completion: {
                self.imagePicker.cameraOverlayView = self.cameraOverlayView(mode: .picture)
                // self.imagePicker.takePicture()
            })
        }
    }
    
    @IBAction func goPhotosApp(_ sender: Any) {
        openPhotosApp()
    }
    
    func clickRecordButton() {
        if let closeButton = imagePicker.cameraOverlayView?.viewWithTag(1000) {
            closeButton.isHidden = isRecording
        }
        
        if isRecording {
            imagePicker.startVideoCapture()
            startCounting()
        }else{
            imagePicker.stopVideoCapture()
            stopCounting()
        }
        
        isRecording = !isRecording
    }
    
    func clickPictureButton() {
        imagePicker.takePicture()
        if let label = imagePicker.cameraOverlayView?.viewWithTag(1001) as? UILabel {
            takenPictureCount += 1
            label.text = "Taken Picture count \(takenPictureCount)"
        }
    }
    
    func clickRotateButton() {
        imagePicker.rotate()
        
        if let button = imagePicker.cameraOverlayView?.viewWithTag(1002) as? UIButton {
            button.isEnabled = false
        }
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableButton), userInfo: nil, repeats: false)
    }
    
    func startCounting() {
        recordingTime = 0.0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateStateLabel), userInfo: nil, repeats: true)
    }
    
    func stopCounting() {
        timer!.invalidate()
        
        if let label = imagePicker.cameraOverlayView?.viewWithTag(1001) as? UILabel {
            label.text = "Saved, recording time \(recordingTime)"
        }
    }
    
    func enableButton() {
        if let button = imagePicker.cameraOverlayView?.viewWithTag(1002) as? UIButton {
            button.isEnabled = true
        }
    }
    
    func updateStateLabel(timer: Timer) {
        if let label = imagePicker.cameraOverlayView?.viewWithTag(1001) as? UILabel {
            recordingTime += 0.1
            label.text = String(recordingTime)
        }
    }

    func closeCamera() {
        takenPictureCount = 0
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: IngCaVMProtocol {
    
    // MARK:
    // MARK: Draw UI
    func cameraOverlayView(mode: CameraMode) -> UIView {
        let size = self.view.frame.size
        let overlayView = UIView.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlayView.backgroundColor = .clear
        
        if mode == .video {
            overlayView.addSubViews(views: [videoRecordingButton])
        } else if mode == .picture {
            overlayView.addSubViews(views: [photoShutterButton])
        }
        
        overlayView.addSubViews(views: [cameraRotateButton, stateLabel, closeButton])
        
        return overlayView
    }
    
    // Video Button
    var videoRecordingButton: UIButton {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: (self.view.frame.size.width / 2) - 25,
                              y: self.view.frame.size.height - 80,
                              width: 50,
                              height: 50)
        button.backgroundColor = .blue
        button.setTitle("shot", for: .normal)
        button.addTarget(self, action: #selector(clickRecordButton), for: .touchUpInside)
        
        return button
    }
    
    
    
    // Picture Button
    var photoShutterButton: UIButton {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: (self.view.frame.size.width / 2) - 25,
                              y: self.view.frame.size.height - 80,
                              width: 50,
                              height: 50)
        button.backgroundColor = .blue
        button.setTitle("shot", for: .normal)
        button.addTarget(self, action: #selector(clickPictureButton), for: .touchUpInside)
        
        return button
    }
    
    
    
    var cameraRotateButton: UIButton {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: self.view.frame.size.width - 60,
                              y: self.view.frame.size.height - 80,
                              width: 50,
                              height: 50)
        button.backgroundColor = .blue
        
        button.tag = 1002
        
        button.setTitle("rotate", for: .normal)
        button.addTarget(self, action: #selector(clickRotateButton), for: .touchUpInside)
        
        return button
    }
    
    var stateLabel: UILabel {
        let frame = CGRect(x: (self.view.frame.size.width / 2) - 100, y: 0, width: 200, height: 30)
        let label = UILabel(frame: frame)
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        
        label.tag = 1001
        
        return label
    }
    
    var closeButton: UIButton {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        button.tag = 1000
        
        button.setTitle("X", for: .normal)
        button.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        
        return button
    }
}

// MARK:
// MARK: UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as NSString as String){
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage

            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }else if(mediaType.isEqual(to: kUTTypeMovie as NSString as String)) {
            if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
                UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath, self, #selector(videoWasSavedSuccessfully(_:didFinishSavingWithError:context:)), nil)
            }
        }
    }
    
    func videoWasSavedSuccessfully(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let error = error {
            print("An error happened while saving the video = \(error)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                // What you want to happen
            })
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("An error happened while saving the video = \(error)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                // What you want to happen
            })
        }
    }
}
