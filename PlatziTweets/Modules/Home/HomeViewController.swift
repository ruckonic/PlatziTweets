//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/10/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {

//    MARK: - IBOutlet
    @IBOutlet weak var tableView : UITableView!
    
//    MARK: Properties
    private let tweetCell = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getPost()
    }
    
    private func setupUI() {
        // 1. Asignar datasource
        self.tableView.dataSource = self
        self.tableView.delegate = self
                
        // 2. Registrar celda
        self.tableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
    }
    
    private func getPost() {
//        1. Indicar carga al usuario
        SVProgressHUD.show()
        SN.get(endpoint: Endpoints.getPosts) { (result: SNResultWithEntity<[Post], ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch result {
                case .success(let posts):
                    self.dataSource = posts
                    self.tableView.reloadData()
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
    
    private func deletePostAt(indexPath: IndexPath) {
        // 1. Indicar carga al usuario
        SVProgressHUD.show()
        
        // 2. Obtener Id del post que se borrará
        let postId = dataSource[indexPath.row].id
        
        // 3. Preparar el endpoint para borrar
        let endpoint = Endpoints.delete + postId
        
        // 4. Consumir el servicio para borrar el post
        SN.delete(endpoint: endpoint) { (result: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch result {
                case .success:
                    // 1. Borrar el post del datasource
                    self.dataSource.remove(at: indexPath.row)
                    
                    // 2. Borrar la celda de la tabla
                    self.tableView.deleteRows(at: [indexPath], with: .left)
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


// MARK: - UITableViewDataSource
extension HomeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tweetCell, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell {
//          Configurar la celda
            cell.setupCell(post: dataSource[indexPath.row])
            cell.needToShowVideo = {url in
                // Aqui si se deberia abrir un viewcontroller
                
                
                let avPlayer = AVPlayer(url: url)
                
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    avPlayerController.player?.play()
                }
            }
        }
        return cell
    }
    
    
    
}

// MARK: - UITableViewDelegate
extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
//            Aqui borramos el tweet
            self.deletePostAt(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let key = UserDefaults.standard.string(forKey: "mail")
        return dataSource[indexPath.row].author.email == key
        
    }
}

// MARK: - Navegation
extension HomeViewController {
    // Este metodo se llamara cuando hagamos transiciones entre pantallas (solo con storyboard)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. validar que el segue sea el esperado
        if segue.identifier == "showMap", let mapVewController = segue.destination as? MapViewController {
            // Aqui si ya sabemos que vamos hacia la pantalla
            mapVewController.posts = self.dataSource.filter{ $0.hasLocation }
            
        }
    }
}
