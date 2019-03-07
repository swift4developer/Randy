//
//  myChat.swift
//  RandyChatApp
//
//  Created by Magneto on 02/03/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class myChat: UIViewController {

    @IBOutlet weak var txtMessage: BorderedTextField!
    @IBOutlet weak var tblView: UITableView!
    
    var myArray = [String]() {
        didSet {
            self.tblView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    @IBAction func btnSendClk(_ sender: Any) {
        if let message = txtMessage.text  {
            if message != "" {
                myArray.append(txtMessage.text! )
                tblView.reloadData()
                txtMessage.text = ""
            }
        }
    }
    
}

extension myChat: UITextFieldDelegate {
    
}

extension myChat :UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if myArray != nil {
        return self.myArray.count
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MyChatDetailCell = tableView.dequeueReusableCell(withIdentifier: "MyChatDetailCell") as! MyChatDetailCell
        
//        if myArray != nil {
            cell.lblDate.text = "02 March 2018"
        cell.lblChatDescription.text = myArray[indexPath.row]
//        }
        
        
        return cell
    }
}
