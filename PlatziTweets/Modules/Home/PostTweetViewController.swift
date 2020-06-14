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
import FirebaseStorage

class PostTweetViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var newPostTextView : UITextView!
    @IBOutlet weak var previewImageView : UIImageView!
    
    // MARK: - IBActions
    @IBAction func dimissView(_ sender : UIView){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender : UIView){
        self.uploadPhotoToFirebase()
    }
    
    @IBAction func openCameraAction() {
        self.openCamera()
    }
    
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    
    // MARK: - Methods
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
    
    private func uploadPhotoToFirebase() {
        // 1. Asegurarnos que la foto exista
        // 2. Comprimir la imagen y convertirla en Data
        guard let imageSaved = previewImageView.image, let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        SVProgressHUD.show()
        
        // 3. Configuaracion para guardar la foto en firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 4. Referencias al storage de firebase
        let storage = Storage.storage()
        
        // 5. Crear nombre de la imagen a subir
        let imageName = Int.random(in: 100...1000)
        
        // 6. Referecia a la carpeta donde se guardara la foto
        let folderReference = storage.reference(withPath: "fotos-tweet/\(imageName).jpg")
        
        // 7. Subir la foto a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                if let error = error {
                    NotificationBanner(title: "Error", subtitle: "\(error.localizedDescription)", style: .warning).show()
                    return
                }
                
                // Obtener la URL de descarga
                folderReference.downloadURL { (url: URL?, error: Error?) in
                    let downloadUrl = url?.absoluteString ?? ""
                    self.submitPost(imageUrl: downloadUrl)
                }
            }
        }
        
    }
    
    private func setupUI() {
        self.newPostTextView.text = "Crea un Tweet"
    }
    
    private func submitPost(imageUrl: String?) {
        guard let tweet = newPostTextView.text, !tweet.isEmpty else {
            NotificationBanner(subtitle: "El tweet esta vacio", style: .warning).show()
            
            return
        }
        let request = PostRequest(text: tweet, imageUrl: imageUrl, videoUrl: nil, location: nil)
        SVProgressHUD.show()
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
