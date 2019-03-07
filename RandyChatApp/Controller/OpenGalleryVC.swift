//
//  OpenGalleryVC.swift
//  RandyChatApp
//
//  Created by Magneto on 22/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class OpenGalleryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tappedAround))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func tappedAround() {
        self.dismiss(animated: false, completion: nil)
    }

}
