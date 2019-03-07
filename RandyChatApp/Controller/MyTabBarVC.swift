//
//  MyTabBarVC.swift
//  RandyChatApp
//
//  Created by Magneto on 10/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class MyTabBarVC: UITabBarController {

    var successMessage:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        if successMessage != nil {
            self.view.makeToast(successMessage!)
        }
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        tabBar.unselectedItemTintColor = color.themeDarkGray
    }
}
