//
//  LeaveChatInfoVC.swift
//  RandyChatApp
//
//  Created by Magneto on 21/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class LeaveChatInfoVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblLeaveChatTitle: UILabel!
    @IBOutlet weak var leaveView: TopRoundedCorners!
    @IBOutlet weak var confirmationPopUpView: UIView!
    @IBOutlet weak var lblLeaveDetails: UILabel!
    @IBOutlet weak var lblMatchBeacuseOf: UILabel!
    @IBOutlet weak var lblNumberOfUsers: UILabel!
    
    @IBOutlet weak var btnLeave: RoundedButton!
    
    @IBOutlet weak var btnLeaveHeight: NSLayoutConstraint!
    var objChatList:chatList!
    
    var groupName = ""
    var chatStartTime = ""
    var total = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if objChatList.isLeave == "1" {
            btnLeave.isHidden = true
            btnLeaveHeight.constant = 0
        } else {
            btnLeave.isHidden = false
            btnLeaveHeight.constant = 40
        }
        
        self.confirmationPopUpView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tappedAround))
        self.view.addGestureRecognizer(tap)
        
        if groupName != "" {
            lblMatchBeacuseOf.text = groupName
        }
        if chatStartTime != "" {
            lblDateTime.text = chatStartTime
        }
        if total != "" {
            lblNumberOfUsers.text = total
        }
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    @IBAction func btnYesClk(_ sender: Any) {
        leaveChat()
    }
    
    @IBAction func btnLeaveClk(_ sender: Any) {
        self.confirmationPopUpView.isHidden = false
    }
    
    @IBAction func btnNoClk(_ sender: Any) {
        self.confirmationPopUpView.isHidden = true
    }
    @objc func tappedAround() {
        self.dismiss(animated: false, completion: nil)
    }
}


extension LeaveChatInfoVC {
    
    //http://sale24by7.com/randy_chat_dev/public/index.php/api/leaveChat?userId=1&privateKey=Sc3pucK8b8qQrvT5&groupId=1&leaveFlag=1
    
    func leaveChat() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "groupId" : objChatList.groupId!,
            "leaveFlag" : "1"
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "leaveChat?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfleaveChat(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func callWSOfleaveChat(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.confirmationPopUpView.isHidden = true
                    self.view.makeToast((JSONResponse["message"] as? String)!)
                    self.dismiss(animated: false, completion: nil)
                    
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
