//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Rene Corrales on 6/5/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: -Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    private func setupUI(){
        self.loginButton.layer.cornerRadius = 25
    }

}
