//
//  ViewController.swift
//  ingca-beta
//
//  Created by Loannes on 2017. 7. 6..
//  Copyright © 2017년 Loannes. All rights reserved.
//

import UIKit

import MobileCoreServices






// Video
protocol IngCaVideoProtocol {
    func clickRecordButton()
}

class VideoControlButton: UIButton {
    var delegate: IngCaVideoProtocol? = nil
    
    func clickRecordButton() {
        delegate?.clickRecordButton()
    }
}




// Picture
protocol IngCaPictureProtocol {
    func clickPictureButton()
}

class PictureControlButton: UIButton {
    var delegate: IngCaPictureProtocol? = nil
    
    func clickPictureButton() {
        delegate?.clickPictureButton()
    }
}









protocol IngCaProtocol {
    var    newMedia: Bool { get }
    var isRecording: Bool { get }

    var imagePicker: UIImagePickerController { get }
    
    func openPhotosApp()
}

extension IngCaProtocol {
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







class ViewController: UIViewController, IngCaProtocol, IngCaVideoProtocol, IngCaPictureProtocol {

    var    newMedia: Bool = false
    var isRecording: Bool = false
    let imagePicker: UIImagePickerController = UIImagePickerController()

    @IBAction func takeVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            imagePicker.videoQuality = .typeHigh
            imagePicker.showsCameraControls = false

            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            let cameraOverlayView = UIView(frame: frame)
            cameraOverlayView.backgroundColor = .clear
            cameraOverlayView.addSubview(createRecordButton())
            cameraOverlayView.addSubview(closeButton())
            cameraOverlayView.addSubview(createCounterLabel())
            
            self.present(imagePicker, animated: true, completion: {
                self.imagePicker.cameraOverlayView = cameraOverlayView
                // self.imagePicker.takePicture()
            })
            newMedia = true     // 이 사진이 새로 만들어진 것이며 카메라 롤에 있던 사진이 아님을 공지
            isRecording = true
        }
    }
    
    @IBAction func takePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera           // 미디어 소스는 카메라로 정의
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]               // 동영상은 지원하지 않으므로 사진으로만 설정
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false
            
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            let cameraOverlayView = UIView(frame: frame)
            cameraOverlayView.backgroundColor = .clear
            cameraOverlayView.addSubview(createPictureButton())
            cameraOverlayView.addSubview(closeButton())
            
            self.present(imagePicker, animated: true, completion: {
                self.imagePicker.cameraOverlayView = cameraOverlayView
                // self.imagePicker.takePicture()
            })
            newMedia = true     // 이 사진이 새로 만들어진 것이며 카메라 롤에 있던 사진이 아님을 공지
        }
    }
    
    @IBAction func goPhotosApp(_ sender: Any) {
        openPhotosApp()
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func clickPictureButton() {
        imagePicker.takePicture()
    }
    
    
    
    
    var count: Float = 0.0
    var timer: Timer?
    
    func updateLabel(timer: Timer) {
        if let label = imagePicker.cameraOverlayView?.viewWithTag(1001) as? UILabel {
            count += 0.1
            label.text = String(count)
        }
    }
    
    func clickRecordButton() {
        if isRecording {
            imagePicker.startVideoCapture()
            isRecording = false
            count = 0.0
            
            imagePicker.cameraOverlayView?.viewWithTag(1000)?.isHidden = true
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
            
            print("record Start")
        }else{
            imagePicker.stopVideoCapture()
            isRecording = true
            
            imagePicker.cameraOverlayView?.viewWithTag(1000)?.isHidden = false
            
            if let label = imagePicker.cameraOverlayView?.viewWithTag(1001) as? UILabel {
                timer!.invalidate()
                timer = nil
                label.text = "Saved, recording time \(count)"
            }
            
            print("record end")
        }
    }
    
    func closeButton() -> UIButton {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.backgroundColor = .blue
        button.tag = 1000
        
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        
        return button
    }
    
    func closeCamera() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as NSString as String){
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage

            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }else if(mediaType.isEqual(to: kUTTypeMovie as NSString as String)) {
            if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
                UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath, self, #selector(videoWasSavedSuccessfully(_:didFinishSavingWithError:context:)), nil)
            }
        }
        
        print("Save")
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
    
    
    
    
    
    
    func createCounterLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: (self.imagePicker.view.frame.size.width / 2) - 100,
                                          y: 0,
                                          width: 200,
                                          height: 30))
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.text = "0.0"
        label.tag = 1001
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        
        return label
    }
    
    func createRecordButton() -> VideoControlButton {
        let button = VideoControlButton.init(type: .system)
        button.frame = CGRect(x: (self.imagePicker.view.frame.size.width / 2) - 25,
                              y: self.imagePicker.view.frame.size.height - 80,
                              width: 50,
                              height: 50)
        button.backgroundColor = .blue
        button.delegate = self
        
        button.setTitle("shot", for: .normal)
        button.addTarget(self, action: #selector(clickRecordButton), for: .touchUpInside)
        
        return button
    }
    
    func createPictureButton() -> PictureControlButton {
        let button = PictureControlButton.init(type: .system)
        button.frame = CGRect(x: (self.imagePicker.view.frame.size.width / 2) - 25,
                           y: self.imagePicker.view.frame.size.height - 80,
                           width: 50,
                           height: 50)
        button.backgroundColor = .blue
        button.delegate = self
        
        button.setTitle("shot", for: .normal)
        button.addTarget(self, action: #selector(clickPictureButton), for: .touchUpInside)
        
        return button
    }
}
