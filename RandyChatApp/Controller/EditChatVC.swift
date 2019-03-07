//
//  EditChatVC.swift
//  RandyChatApp
//
//  Created by Magneto on 22/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class EditChatVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var lblCustomName: SkyFloatingLabelTextField!
    @IBOutlet weak var lblSearchedText: UILabel!
    @IBOutlet weak var btnSave: RoundedButton!
    @IBOutlet weak var nameWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnSaveHeight: NSLayoutConstraint!
    var originalName = ""
    var chatName = ""
    
    var objChatList:chatList!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if objChatList.isLeave == "1" {
            lblCustomName.isUserInteractionEnabled = false
            btnSave.isHidden = true
            btnSaveHeight.constant = 0
        } else {
            lblCustomName.isUserInteractionEnabled = true
            btnSave.isHidden = false
            btnSaveHeight.constant = 35
        }
        
        lblCustomName.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tappedAround))
        self.view.addGestureRecognizer(tap)
        
        if originalName != ""{
            lblSearchedText.text = originalName
        }
        if chatName != "" {
            nameWidthConstraint.constant = chatName.widthOfString(usingFont: UIFont.init(name: "Nunito-Regular", size: 14.0)!)
            lblCustomName.text = chatName
        }
    }
    @IBAction func btnSaveClk(_ sender: Any) {
        if chatName != lblCustomName.text {
            updateGroupName()
        }
    }
    
    @objc func tappedAround() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
}

extension EditChatVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.nameWidthConstraint.constant = (lblCustomName.text?.widthOfString(usingFont: UIFont.init(name: "Nunito-Regular", size: 14.0)!))!
        
        return true
    }
}


extension EditChatVC {
    
    func updateGroupName() {
        
        let groupName = lblCustomName.text!
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "groupId" : objChatList.groupId!,
            "groupName" : groupName
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "updateGroupName?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfupdateGroupName(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    
    
    func callWSOfupdateGroupName(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    
                    
                }else{
                    if let errorCode = JSONResponse["errorCode"] as? String {
                        if errorCode == "99" {
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else {
                        self.view.makeToast((JSONResponse["message"] as? String)!)
                    }
                }
            }
        }, failure: { (error) in
            print("error: ",error)
            DispatchQueue.main.async{
                self.view.makeToast(string.someThingWrongMsg)
                self.stopActivityIndicator()
            }
        })
    }
}
