//
//  MyChatView.swift
//  RandyChatApp
//
//  Created by Aditya on 14/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class MySelectChatView: UIViewController {
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tblChatList: UITableView!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var bottomViewHeightConstrain: NSLayoutConstraint!
    
    var arrMessages = [Messages]() {
        didSet {
            self.tblChatList.reloadData()
        }
    }
    var objChatList: chatList!
    var userId = ""
    var email = ""
    var isMyConsecutiveMyMsg = "0"
    var isOtherConsecutiveMyMsg = "0"
    var totalMessages = 0
    var groupName = ""
    var chatStartTime = ""
    var total = ""
    var originalName = ""
    var chatName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if objChatList.isLeave == "1" {
            bottomView.isHidden = true
            bottomViewHeightConstrain.constant = 0
        } else {
            bottomView.isHidden = false
            bottomViewHeightConstrain.constant = 60
        }
        
        if UserDefaults.standard.value(forKey: UserPreference.UserDetails) != nil {
            var dict = UserDefaults.standard.value(forKey: UserPreference.UserDetails) as! [String:String]
            userId = dict["userId"] ?? ""
            email =  dict["email"] ?? ""
        }
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color.themeSkyBlue]
        self.setBackButton()
        
        if let topTitle = objChatList.discussionTitle {
            self.title = topTitle
        }
        
        
        self.setRightNavigationButtons()
        
        self.tblChatList.dataSource = self
        self.tblChatList.delegate = self
//        self.tblChatList.rowHeight = UITableView.automaticDimension
//        self.tblChatList.estimatedRowHeight = 60
        self.sendChatData()
        self.fetchMessages()
        self.getGroupInfo()
        self.getGroupName()
        self.updateGroupStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
       //self.tblChatList.layoutSubviews()
    }
    override func viewWillLayoutSubviews() {
        
    }
    @IBAction func btnAttachClk(_ sender: Any) {
        let gallery = self.storyboard?.instantiateViewController(withIdentifier: "OpenGalleryVC") as! OpenGalleryVC
        gallery.modalPresentationStyle = .overCurrentContext
        gallery.view.backgroundColor = color.bgColor
        self.present(gallery, animated: false, completion: nil)
    }
    @IBAction func btnSendClk(_ sender: UIButton) {
        self.sendChatData()
    }
    
    func setRightNavigationButtons() {
        let btnEdit = UIButton(frame: CGRect(x: 0, y:0, width:30,height: 30))
        btnEdit.setImage(UIImage(named:"edit"), for: .normal)
        btnEdit.addTarget(self,action: #selector(editClk), for: .touchUpInside)
        let widthConstraint = btnEdit.widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = btnEdit.heightAnchor.constraint(equalToConstant: 30)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let btnMore = UIButton(frame: CGRect(x: 0, y:0, width:28,height: 30))
        btnMore.setImage(UIImage(named:"more"), for: .normal)
        btnMore.addTarget(self,action: #selector(moreClk), for: .touchUpInside)
        let widthConstraint1 = btnMore.widthAnchor.constraint(equalToConstant: 28)
        let heightConstraint1 = btnMore.heightAnchor.constraint(equalToConstant: 30)
        heightConstraint1.isActive = true
        widthConstraint1.isActive = true
        
        let editBarButton = UIBarButtonItem(customView: btnEdit)
        let moreBarButton = UIBarButtonItem(customView: btnMore)
        let arrRightBarButtonItems : Array = [moreBarButton,editBarButton]
        self.navigationItem.rightBarButtonItems = arrRightBarButtonItems
    }
    
    func setBackButton() {
        let btnEdit = UIButton(frame: CGRect(x: 0, y:0, width:22,height: 22))
        btnEdit.setImage(UIImage(named:"back"), for: .normal)
        btnEdit.addTarget(self,action: #selector(backClk), for: .touchUpInside)
        let widthConstraint = btnEdit.widthAnchor.constraint(equalToConstant: 22)
        let heightConstraint = btnEdit.heightAnchor.constraint(equalToConstant: 22)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let editBarButton = UIBarButtonItem(customView: btnEdit)
        let arrRightBarButtonItems = editBarButton
        self.navigationItem.leftBarButtonItem = arrRightBarButtonItems
    }
    
    @objc func editClk() {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditChatVC") as! EditChatVC
        editVC.objChatList = objChatList
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.view.backgroundColor = color.bgColor
        editVC.originalName = originalName
        editVC.chatName = chatName
        self.present(editVC, animated: false, completion: nil)
        
        
    }
    @objc func moreClk() {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "LeaveChatInfoVC") as! LeaveChatInfoVC
        infoVC.objChatList = objChatList
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.view.backgroundColor = color.bgColor
        infoVC.chatStartTime = chatStartTime
        infoVC.total = total
        infoVC.groupName = groupName
        self.present(infoVC, animated: false, completion: nil)
    }
    
    @objc func backClk() {
        updateGroupStatus()
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendChatData() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let strDate = dateFormatter.string(from: currentDate)
        
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        if let id = uid {
            
            if txtChat.text?.isEmpty != true {
                
                let bodyData: [String:Any] = [SendMessageParameters.groupId: id,
                                              SendMessageParameters.message: txtChat.text!,
                                              SendMessageParameters.discussionTitle: objChatList.discussionTitle ?? "",
                                             SendMessageParameters.profileName:objChatList.profileName ?? "",
                                              SendMessageParameters.lastChatTime:strDate,
                                              SendMessageParameters.chatUserId:objChatList.chatUserId ?? "",
                                              SendMessageParameters.userId:userId,
                                              SendMessageParameters.userEmail:email]
                
                if let id = objChatList.groupId {
                    
                    ref.child("Message").child(id).childByAutoId().setValue(bodyData)
                    //            ref.child("Message").child("Adeesh").setValue(bodyData)
                }
            }
            
        } else {
            print("id is nill")
        }
        
        
    }
    
    func fetchMessages() {
        _ = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        
        
        
        if let id = objChatList.groupId {
            //        get all user data
            ref.child("Message").child(id).observe(.value) { (data) in
                print(data)
                self.totalMessages = Int(data.childrenCount)
            }
            
            
            ref.child("Message").child(id).queryOrderedByKey().observe(.childAdded) { (sanpShot) in
                print(sanpShot)
                
                
                if let value = sanpShot.value {
                    
                    self.arrMessages.append(Messages.init(
                        GroupId:  (value as! NSDictionary).value(forKey: "GroupId") as? String ?? "",
                        Message: (value as! NSDictionary).value(forKey: "message") as? String ?? "",
                        DiscussionTitle: (value as! NSDictionary).value(forKey: "discussionTitle") as? String ?? "",
                        ProfileName: (value as! NSDictionary).value(forKey: "profileName") as? String ?? "",
                        LastChatTime: (value as! NSDictionary).value(forKey: "lastChatTime") as? String ?? "",
                        ChatUserId: (value as! NSDictionary).value(forKey: "chatUserId") as? String ?? "",
                        UserId: (value as! NSDictionary).value(forKey: "userId") as? String ?? "",
                        UserEmail: (value as! NSDictionary).value(forKey: "userEmail") as? String ?? ""))
                }
            }
        }
    }
}


extension MySelectChatView :UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectObj = self.arrMessages[indexPath.row]
        if selectObj.userId == userId {
            if isMyConsecutiveMyMsg == "0" {
                let cell : MyChatDetailCell = tableView.dequeueReusableCell(withIdentifier: "MyChatDetailCell") as! MyChatDetailCell
                isMyConsecutiveMyMsg = "1"
                
                cell.lblDate.text = selectObj.lastChatTime
                cell.lblChatDescription.text = selectObj.message
                //                cell.profilePic.image
                
                return cell
            } else {
                let cell : MyChatDefaultCell = tableView.dequeueReusableCell(withIdentifier: "MyChatDefaultCell") as! MyChatDefaultCell
                isMyConsecutiveMyMsg = "0"
                cell.lblDate.text = selectObj.lastChatTime
                cell.lblChatDescription.text = selectObj.message
                
                
                return cell
            }
        } else {
            
            if  isOtherConsecutiveMyMsg == "0" {
                let cell : ClientChatDetailCell = tableView.dequeueReusableCell(withIdentifier: "ClientChatDetailCell") as! ClientChatDetailCell
                isOtherConsecutiveMyMsg = "1"
                
                cell.lblDate.text = selectObj.lastChatTime
                cell.lblChatDescription.text = selectObj.message
                //                cell.profilePic.image
                
                return cell
            } else {
                let cell : ClientChatDefaultCell = tableView.dequeueReusableCell(withIdentifier: "ClientChatDefaultCell") as! ClientChatDefaultCell
                isOtherConsecutiveMyMsg = "0"
                cell.lblDate.text = selectObj.lastChatTime
                cell.lblChatDescription.text = selectObj.message
                
                
                return cell
            }
        }
    }
}

extension MySelectChatView {
    //http://sale24by7.com/randy_chat_dev/public/index.php/api/getGroupInfo?userId=1&privateKey=q7hly9bCDg8ry2YU&groupId=1
    func getGroupInfo() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "groupId" : objChatList.groupId!
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "getGroupInfo?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            //startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetGroupInfo(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    
    func callWSOfgetGroupInfo(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            //self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    if let groupName = JSONResponse["groupName"] as? String {
                        self.groupName = groupName
                    }
                    if let chatStartTime = JSONResponse["chatStartTime"] as? String {
                        self.chatStartTime = chatStartTime
                    }
                    if let totalUser = JSONResponse["totalUser"] as? String {
                        self.total = totalUser
                    }
                }else{
                    if let errorCode = JSONResponse["errorCode"] as? String {
                        if errorCode == "99" {
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            self.navigationController?.popToRootViewController(animated: true)
                        }else {
                            self.view.makeToast(string.someThingWrongMsg)
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
                //self.stopActivityIndicator()
            }
        })
    }
}

extension MySelectChatView {
    //http://sale24by7.com/randy_chat_dev/public/index.php/api/getGroupName?userId=1&privateKey=y34Jq0kjPn2Y7apJ&groupId=1
    func getGroupName() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "groupId" : objChatList.groupId!
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "getGroupName?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            //startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetGroupName(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func callWSOfgetGroupName(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            //self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    if let originalName = JSONResponse["originalName"] as? String {
                        self.originalName = originalName
                    }
                    if let chatName = JSONResponse["chatName"] as? String {
                        self.chatName = chatName
                    }
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
                //self.stopActivityIndicator()
            }
        })
    }
}

//MARK:- updateGroupStatus API
extension MySelectChatView {
   
    func updateGroupStatus() {
        //http://sale24by7.com/randy_chat_dev/public/index.php/api/updateGroupStatus?userId=1&privateKey=gvuRYnehhQC0bQla&groupId=1&totalChatNumber=2&lastChatTime=Feb%2025th,%2011:09%20pm&startChatTime=Feb%2024th,%2011:09%20pm
        
        var group_id = ""
        if let groupId = objChatList.groupId {
            group_id = groupId
        }
        var last_chatTime = ""
        if let lastChatTime = objChatList.groupId {
            last_chatTime = lastChatTime
        }
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "groupId" : group_id,
            "totalChatNumber" : "\(totalMessages)",
            "lastChatTime": last_chatTime,
            "startChatTime" : last_chatTime
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "updateGroupStatus?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            //startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfupdateGroupStatus(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    
    func callWSOfupdateGroupStatus(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            //self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    if let errorCode = JSONResponse["errorCode"] as? String {
                        if errorCode == "99" {
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            self.navigationController?.popToRootViewController(animated: true)
                        }else {
                            self.view.makeToast(string.someThingWrongMsg)
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
                //self.stopActivityIndicator()
            }
        })
    }
}
