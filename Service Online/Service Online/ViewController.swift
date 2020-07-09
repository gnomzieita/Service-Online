//
//  ViewController.swift
//  Service Online
//
//  Created by Alex Agarkov on 2/27/19.
//  Copyright © 2019 YobiByte LLC. All rights reserved.
//

import UIKit
import Alamofire



class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTap(_ sender: Any) {
        if let correctPass = pass.text {
            if let correctEmail = email.text {
                SO_API.shared.login(email: correctEmail, password: correctPass) { (success, response) in
                    if success!, let responseDict = response {
                        debugPrint(responseDict)
                        self.performSegue(withIdentifier: "loginOk", sender: self)
                    }
                }
            }
        }
    }
    
}

