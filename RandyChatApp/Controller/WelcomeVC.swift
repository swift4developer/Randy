//
//  WelcomeVC.swift
//  RandyChatApp
//
//  Created by Magneto on 03/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var btnSignIn: RoundedButton!
    @IBOutlet weak var btnSignUp: RoundedButton!
    @IBOutlet weak var lblWelcomeTitle: UILabel!
    @IBOutlet weak var imgWelcome: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if loggedIn == true{
            let myChat = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarVC") as! MyTabBarVC
            self.navigationController?.pushViewController(myChat, animated: false)
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func btnSignUpClk(_ sender: Any) {
        let login = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(login, animated: true)
    }
    
    @IBAction func btnSignInClk(_ sender: UIButton) {
        let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(login, animated: true)
    }
}
