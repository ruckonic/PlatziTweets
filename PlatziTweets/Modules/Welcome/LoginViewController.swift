//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Rene Corrales on 6/5/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    @IBAction func loginActionButton(_ sender: UIButton){
        view.endEditing(true)
        self.performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    // MARK: - Private methods
    private func setupUI(){
       self.loginButton.layer.cornerRadius = 25
    }
    
    private func performLogin() {
        guard let email:String = mailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "E-mail is empty", style: .warning).show()
            return
        }
        
        guard let password:String = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Password is empty", style: .warning).show()
            return
        }
        SVProgressHUD.show()
//        Crear Request
        let request = LoginRequest(email: email, password: password)
        
//        Call the network library
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
                case .success(let user):
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                    UserDefaults.standard.set(user.user.email, forKey: "mail")
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
