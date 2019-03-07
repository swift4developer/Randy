//
//  SearchTopicVC.swift
//  RandyChatApp
//
//  Created by Magneto on 14/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchTopicVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var txtFieldSearchTopics: UITextField!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var tblViewOfTopics: UITableView!
    
    var timeOut: Timer!
    
    var arrayOfTopics = [[String:Any]]()
    var selectedTopicID = ""
    
    var userTopicId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFieldSearchTopics.delegate = self
        tblViewOfTopics.tableFooterView = UIView()
        
        
        self.getTopics()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    @objc func cancelWeb() {
        let gallery = self.storyboard?.instantiateViewController(withIdentifier: "NoSearchResultVC") as! NoSearchResultVC
        gallery.modalPresentationStyle = .overCurrentContext
        gallery.view.backgroundColor = color.bgColor
        self.present(gallery, animated: false, completion: nil)
        
    }
    
    
    @objc func ApiCallWithUserTopicId() {
        if txtFieldSearchTopics.text?.isEmpty != true {
            self.searchUsers(searchKeyword: txtFieldSearchTopics.text!.lowercased(), userTopicId: self.userTopicId, isSecond: true)
        }
        
    }
    
}

extension SearchTopicVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtFieldSearchTopics {
            if textField.text?.isEmpty != true {
                searchUsers(searchKeyword: textField.text!.lowercased(), userTopicId: "",isSecond: false)
            }
        }
    }
}

extension SearchTopicVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myChatCell", for: indexPath) as! myChatTableViewCell
        let dict = arrayOfTopics[indexPath.row]
        cell.lblOfSearchResult.text = dict["topicName"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrayOfTopics[indexPath.row]
        selectedTopicID = dict["topicId"] as! String
    }
}

extension SearchTopicVC {
    func getTopics() {
        
        //http://sale24by7.com/randy_chat_dev/public/index.php/api/getTopics?userId=1&privateKey=Sc3pucK8b8qQrvT5
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "getTopics?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetTopics(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func searchUsers(searchKeyword: String, userTopicId: String,isSecond: Bool) {
        //        http://sale24by7.com/randy_chat_dev/public/index.php/api/searchResult
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "searchString": searchKeyword,
            "userTopicId": userTopicId
        ]
        
        print("I/P:",dictionary)
        
        
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "searchResult?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            //            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfSearchUser(strURL: strURL, dictionary: dictionary)
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
        
        if isSecond == false {
            
            self.timeOut = Timer.scheduledTimer(timeInterval: 60, target: self, selector:
                #selector(ApiCallWithUserTopicId), userInfo: nil, repeats: false)
            
        }
        
    }
    
    
}

//MARK: - WS Of Forgot
extension SearchTopicVC {
    func callWSOfgetTopics(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.arrayOfTopics.removeAll()
                    if let data = JSONResponse["topics"] as? [[String:Any]] {
                        self.arrayOfTopics = data
                    }
                    
                    if let message = JSONResponse["topics"] as? String {
                        self.lblInfo.text = message
                    }
                    
                    DispatchQueue.main.async {
                        self.tblViewOfTopics.reloadData()
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
                self.stopActivityIndicator()
            }
        })
    }
    
    func callWSOfSearchUser(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        
        
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "0"{
                    self.stopActivityIndicator()
                    self.cancelWeb()
                }
                if JSONResponse["status"] as? String == "1"{
                    
                    if JSONResponse["userTopicId"] != nil {
                        if let userTopic = JSONResponse["userTopicId"] as? String {
                            self.userTopicId = userTopic
                        }
                    } else {
                        self.stopActivityIndicator()
                        print("get User")
                        
                        let objChatlist =  Mapper<chatList>().map(JSONObject: JSONResponse)
                        
                        print(objChatlist)
                        
                        
                        
                        
                        ////
                        //                    if JSONResponse["selfProfileName"] != nil {
                        //                        if let profileName = JSONResponse["selfProfileName"] as? String {
                        //                            chatList.profileName = profileName
                        //                        }
                        //                        if let selfProfileImage = JSONResponse["selfProfileImage"] as? String {
                        //                            chatList.profileImage = selfProfileImage
                        //                        }
                        //                        if let groupId = JSONResponse["groupId"] as? String {
                        //                            chatList.groupId = groupId
                        //                        }
                        //                        if let discussionTitle = JSONResponse["discussionTitle"] as? String {
                        //                            chatList.discussionTitle = discussionTitle
                        //                        }
                        //                        if let chatUserId = JSONResponse["chatUserId"] as? String {
                        //                            chatList.chatUserId = chatUserId
                        //                        }
                        //                        if let profileImage = JSONResponse["profileImage"] as? String {
                        //                            chatList.otherUserProfileImage = profileImage
                        //                        }
                        //                        if let profileName = JSONResponse["profileName"] as? String {
                        //                            chatList.otherProfileName = profileName
                        //                        }
                        //                        if let isActive = JSONResponse["isActive"] as? String {
                        //                            chatList.isActive = isActive
                        //                        }
                        ////
                        //                        chatList.isLeave = "1"
                        if let obj = objChatlist {
                            let chatDetails = self.storyboard?.instantiateViewController(withIdentifier: "MySelectChatView") as! MySelectChatView
                            chatDetails.objChatList = obj
                            self.navigationController?.pushViewController(chatDetails, animated: true)
                        }
                        
                        //                    }
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
                self.stopActivityIndicator()
            }
        })
    }
}
