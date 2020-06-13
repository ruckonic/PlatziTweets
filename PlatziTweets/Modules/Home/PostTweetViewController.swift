//
//  PostTweetViewController.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/12/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import SVProgressHUD
import Simple_Networking
import NotificationBannerSwift

class PostTweetViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var newPostTextView : UITextView!
    @IBOutlet weak var previewImageView : UIImageView!
    
    // MARK: - IBActions
    @IBAction func dimissView(_ sender : UIView){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender : UIView){
        self.submitPost()
    }
    
    @IBAction func openCameraAction() {
        self.openCamera()
    }
    
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .auto
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupUI() {
        self.newPostTextView.text = "Crea un Tweet"
    }
    
    private func submitPost() {
        guard let tweet = newPostTextView.text, !tweet.isEmpty else {
            NotificationBanner(subtitle: "El tweet esta vacio", style: .warning).show()
            
            return
        }
        SVProgressHUD.show()
        let request = PostRequest(text: tweet, imageUrl: nil, videoUrl: nil, location: nil)
        
        SN.post(endpoint: Endpoints.post, model: request) { (result : SNResultWithEntity< Post, ErrorResponse>) in
         SVProgressHUD.dismiss()
            switch result {
                case .success:
                    self.dismiss(animated: true, completion: nil)
    //                Todo Correcto
                case .error(let error):
    //                 Todo lo malo
                    NotificationBanner(title: "Error", subtitle: "\(error.localizedDescription)", style: .danger).show()
                    
                case .errorResult(let entity):
    //                    Error no tan malo
                    NotificationBanner(title: "Error", subtitle: "\(entity.error.description)", style: .warning).show()
                    return
            }
        }
    }
        
}

// MARK: - UIImagePickerControllerDelegate
extension PostTweetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Cerrar camara
        imagePicker?.dismiss(animated: true, completion: nil)
        
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            
            // obtener la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
    }
}
