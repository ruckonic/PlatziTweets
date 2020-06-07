//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Rene Corrales on 6/5/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    @IBAction func registerActionButton(_ sender: UIButton){
        view.endEditing(true)
        self.performLogin()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
    }
    

    // MARK: - Private Method
     private func setupUI(){
        self.registerButton.layer.cornerRadius = 25
    }
    
    
    private func performLogin() {
        guard let email:String = mailTextField.text, !email.isEmpty else {
           NotificationBanner(title: "Error", subtitle: "E-mail is empty", style: .warning).show()
           return
       }
       
        guard let name:String = nameTextField.text, !name.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Name is empty", style: .warning).show()
            return
        }
        
       guard let password:String = passwordTextField.text, !password.isEmpty else {
           NotificationBanner(title: "Error", subtitle: "Password is empty", style: .warning).show()
           return
       }
       
       performSegue(withIdentifier: "showHome", sender: nil)
   }

}
