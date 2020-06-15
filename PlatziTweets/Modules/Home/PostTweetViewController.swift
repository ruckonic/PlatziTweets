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
import AVFoundation
import AVKit
import MobileCoreServices

class PostTweetViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var newPostTextView : UITextView!
    @IBOutlet weak var previewImageView : UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func dimissView(_ sender : UIView){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender : UIView){
        self.uploadMediaToFirebase()
    }
    
    @IBAction func openCameraAction() {
        let alert = UIAlertController(title: "Camara", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (_) in
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { (_) in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = self.currentVideoURL else {
            return
        }
        
        let avPlayer = AVPlayer(url: currentVideoURL)
    
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .auto
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self

        guard let imagePicker = imagePicker else {
            return
        }
        
        self.present(imagePicker, animated: true, completion: nil)
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
    
    private func uploadMediaToFirebase() {
        
        
        SVProgressHUD.show()
        
        // 3. Configuaracion para guardar la foto en firebase
        let metaDataConfig = StorageMetadata()
        
        var fileData: Data?
        var fileExtension: String = ""
        var isVideo: Bool = false
        
        if let imageSaved = previewImageView.image {
            
            fileData = imageSaved.jpegData(compressionQuality: 0.1)
            metaDataConfig.contentType = "image/jpg"
            fileExtension = "jpg"
            
        } else if let currentVideoSaveURL = self.currentVideoURL {
            
            fileData = try? Data(contentsOf: currentVideoSaveURL)
            metaDataConfig.contentType = "video/MP4"
            fileExtension = "mp4"
            isVideo = true
        }
        
        // 4. Referencias al storage de firebase
        let storage = Storage.storage()
        
        // 5. Crear nombre de la imagen a subir
        let fileName = Int.random(in: 100...1000)
        
        // 6. Referecia a la carpeta donde se guardara la foto
        let folderReference = storage.reference(withPath: "\(isVideo ? "video" : "photo")-tweet/\(fileName).\(fileExtension)")
        
        // 7. Subir la foto a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(fileData ?? Data(), metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                if let error = error {
                    NotificationBanner(title: "Error", subtitle: "\(error.localizedDescription)", style: .warning).show()
                    return
                }
                
                // Obtener la URL de descarga
                folderReference.downloadURL { (url: URL?, error: Error?) in
                    let downloadUrl = url?.absoluteString ?? nil
                    isVideo ?
                        self.submitPost(imageUrl: nil, videoUrl: downloadUrl)
                        :
                        self.submitPost(imageUrl: downloadUrl, videoUrl: nil)
                }
            }
        }
        
    }
    
    private func setupUI() {
        self.newPostTextView.text = "Crea un Tweet"
    }
    
    private func submitPost(imageUrl: String?, videoUrl: String?) {
        guard let tweet = newPostTextView.text, !tweet.isEmpty else {
            NotificationBanner(subtitle: "El tweet esta vacio", style: .warning).show()
            
            return
        }
        let request = PostRequest(text: tweet, imageUrl: imageUrl, videoUrl: videoUrl, location: nil)
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
        
        if info.keys.contains(.mediaURL) , let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            self.videoButton.isHidden = false
            self.currentVideoURL = recordedVideoUrl
        }
    }
}
